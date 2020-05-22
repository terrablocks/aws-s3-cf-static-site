output "s3_bucket" {
  value = aws_s3_bucket.website_bucket.id
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.website_cdn.id
}

output "cloudfront_endpoint" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}

output "website_endpoints" {
  value = aws_route53_record.website-record.*.fqdn
}
