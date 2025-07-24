data "aws_kms_key" "website_bucket" {
  key_id = var.kms_key
}

resource "aws_s3_bucket" "website_bucket" {
  # checkov:skip=CKV_AWS_18: Access logging not required on bucket as the same can be enabled at CloudFront level if required by user
  # checkov:skip=CKV_AWS_144: CRR not required
  # checkov:skip=CKV_AWS_21: Versioning not required
  # checkov:skip=CKV_AWS_145: SSE encrytion depends on user
  # checkov:skip=CKV_AWS_19: SSE encrytion depends on user
  # checkov:skip=CKV_AWS_52: MFA delete not required
  # checkov:skip=CKV2_AWS_62: Event notification not required
  # checkov:skip=CKV2_AWS_61: Enabling lifecycle configuration depends on user
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = var.bucket_object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key == "alias/aws/s3" ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key == "alias/aws/s3" ? null : data.aws_kms_key.website_bucket.id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = aws_s3_bucket.website_bucket.id
  description                       = "OAC for ${aws_s3_bucket.website_bucket.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = md5(var.bucket_name)
}

resource "aws_cloudfront_distribution" "website_cdn" {
  # checkov:skip=CKV_AWS_310: Origin failover configuration not required
  # checkov:skip=CKV2_AWS_32: Response headers policy not required
  # checkov:skip=CKV2_AWS_47: WAF attachment is dependant on user
  # checkov:skip=CKV2_AWS_42: Attaching custom SSL certificate is dependant on user
  # checkov:skip=CKV_AWS_174: TLS certificate version is dependant on user
  # checkov:skip=CKV_AWS_374: Enabling geo restriction is dependant on user
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_path              = var.origin_path
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  aliases             = length(var.cnames) == 0 ? null : var.cnames
  comment             = var.comment
  web_acl_id          = var.web_acl_id

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambda_functions
      content {
        event_type   = lookup(lambda_function_association.value, "event_type", null)
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn", null)
        include_body = lookup(lambda_function_association.value, "include_body", null)
      }
    }

    dynamic "function_association" {
      for_each = var.cloudfront_functions
      content {
        event_type   = lookup(function_association.value, "event_type", null)
        function_arn = lookup(function_association.value, "function_arn", null)
      }
    }
  }

  price_class = var.price_class

  viewer_certificate {
    cloudfront_default_certificate = length(var.cnames) == 0 ? true : false
    acm_certificate_arn            = length(var.cnames) == 0 ? null : aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method             = length(var.cnames) == 0 ? null : var.ssl_support_method
    minimum_protocol_version       = length(var.cnames) == 0 ? null : var.ssl_cert_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_type == "none" ? null : var.geo_restriction_locations
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = lookup(custom_error_response.value, "error_code", null)
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  dynamic "logging_config" {
    for_each = var.access_logging[*]

    content {
      bucket          = lookup(logging_config.value, "bucket", null)
      include_cookies = lookup(logging_config.value, "include_cookies", null)
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket" # ListBucket permission is required so that CloudFront does not throw 403 (AccessDenied) error in case the requested file does not exists
    ]
    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.website_cdn.arn]
    }
  }

  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = var.bucket_policy == "" ? data.aws_iam_policy_document.website_bucket_policy.json : var.bucket_policy
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us
  domain_name               = element(slice(var.cnames, 0, 1), 0)
  subject_alternative_names = length(var.cnames) > 1 ? slice(var.cnames, 1, length(var.cnames)) : null
  validation_method         = "DNS"
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

resource "aws_route53_record" "cert_record" {
  provider = aws.us
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
}

resource "aws_route53_record" "website_record" {
  count           = length(var.cnames)
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.id
  name            = var.cnames[count.index]
  type            = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
