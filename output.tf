output "s3_bucket" {
  value       = aws_s3_bucket.website_bucket.id
  description = "ID/Name of S3 bucket created for serving static website"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.website_bucket.arn
  description = "ARN of S3 bucket created for serving static website"
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.website_cdn.id
  description = "ID of CloudFront distribution created for serving static website"
}

output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.website_cdn.arn
  description = "ARN of CloudFront distribution created for serving static website"
}

output "cloudfront_endpoint" {
  value       = aws_cloudfront_distribution.website_cdn.domain_name
  description = "Endpoint of CloudFront distribution created for serving static website"
}

output "website_endpoints" {
  value       = local.website_domains
  description = "Alternate domain names created in Route53 for CloudFront distribution"
}
