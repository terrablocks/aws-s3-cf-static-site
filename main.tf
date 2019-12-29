provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}

provider "aws" {
  alias = "us"
  profile = "${var.profile}"
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.bucket_name}"
  acl = "private"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${aws_s3_bucket.website_bucket.id}"
}

locals {
  s3_origin_id = "${md5(var.bucket_name)}"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  origin {
    domain_name = "${aws_s3_bucket.website_bucket.bucket_regional_domain_name}"
    origin_id = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
  }
  
  enabled = true
  default_root_object = "index.html"
  aliases = "${var.cnames}"

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"
    compress = true
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_All"
  viewer_certificate {
    acm_certificate_arn = "${length(var.cnames) == 0 ? "" : "${aws_acm_certificate_validation.cert_validation.certificate_arn}"}"
    cloudfront_default_certificate = "${length(var.cnames) == 0 ? true : false}"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = "${aws_s3_bucket.website_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Principal": {
        "CanonicalUser": "${aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id}"
      },
      "Resource": "${aws_s3_bucket.website_bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_acm_certificate" "cert" {
  provider = "aws.us"
  domain_name = "${element(slice(var.cnames, 0, 1), 0)}"
  subject_alternative_names = "${length(var.cnames) > 1 ? slice(var.cnames, 1, length(var.cnames)) : "${tolist([])}"}"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name = "${var.hosted_zone}"
}

resource "aws_route53_record" "cert_record" {
  count = "${length(var.cnames)}"
  name    = "${aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = "aws.us"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = "${aws_route53_record.cert_record.*.fqdn}"
}

resource "aws_route53_record" "website-record" {
  count = "${length(var.cnames)}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${var.cnames[count.index]}"
  type    = "A"
  
  alias {
    name = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
