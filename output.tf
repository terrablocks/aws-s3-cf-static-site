output "s3_bucket" {
  value = aws_s3_bucket.website_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.website_bucket.arn
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.website_cdn.id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.website_cdn.arn
}

output "cloudfront_endpoint" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}

output "website_endpoints" {
  value = local.website_domains
}
