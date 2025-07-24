<!-- BEGIN_TF_DOCS -->
# Host a Static Website using S3 & CloudFront

![License](https://img.shields.io/github/license/terrablocks/aws-s3-cf-static-site.git?style=for-the-badge) ![Plan](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-s3-cf-static-site.git/tf-plan.yml?branch=main&label=Plan&style=for-the-badge) ![Checkov](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-s3-cf-static-site.git/checkov.yml?branch=main&label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-s3-cf-static-site.git?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-s3-cf-static-site.git?style=for-the-badge)

This terraform module will deploy the following services:
- S3
- CloudFront
- ACM
- Route53 Records

**Important:**
If you are providing custom KMS key for encrypting objects stored in S3 bucket make sure to update KMS key policy to allow CloudFront distribution to access the key. Doc: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html

# Usage Instructions
## Example
```hcl
# Provider for N.Virginia. Make sure to also have a default provider along with this provider
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

module "webapp" {
  source = "github.com/terrablocks/aws-s3-cf-static-site.git?ref=" # Always use `ref` to point module to a specific version or hash

  bucket_name = "webapp"
  cnames      = ["example.com"]
  hosted_zone = "example.com"

  providers = {
    aws.us = aws.use1
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.12.0 |
| aws | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_logging | The logging configuration that controls how logs are written to your distribution ```{ bucket = The Amazon S3 bucket to store the access logs in. Example: bucketname.s3.amazonaws.com include_cookies = Specifies whether you want CloudFront to include cookies in access logs prefix = An optional string that you want CloudFront to prefix to the access log filenames for this distribution }``` | ```object({ bucket = string include_cookies = optional(bool) prefix = optional(string) })``` | `null` | no |
| bucket_name | Name of S3 bucket | `string` | n/a | yes |
| bucket_object_ownership | Specify object ownership method. Possible values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced | `string` | `"BucketOwnerEnforced"` | no |
| bucket_policy | Resource policy to apply on S3 bucket. Leave it blank to generate one automatically | `string` | `""` | no |
| cloudfront_functions | A config block that triggers a CloudFront function with specific actions (maximum 2) ```{ event_type = The specific event to trigger this function. Possible values: viewer-request, viewer-response function_arn = ARN of the CloudFront function to trigger upon certain event }``` | ```list(object({ event_type = string function_arn = string }))``` | `[]` | no |
| cnames | Access CloudFront using a custom domain name | `list(string)` | n/a | yes |
| comment | Description/Comments about distribution | `string` | `"Managed by terrablocks"` | no |
| custom_error_responses | One or more custom error response elements (multiples allowed) ```{ error_caching_min_ttl = The minimum amount of time you want HTTP error codes to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated error_code = The 4xx or 5xx HTTP status code that you want to customize response_code = The HTTP status code that you want CloudFront to return with the custom error page to the viewer response_page_path = The path of the custom error page. Example: /404.html. Make sure the file 404.html is present within the origin }``` | ```list(object({ error_code = number error_caching_min_ttl = optional(number) response_code = optional(number) response_page_path = optional(string) }))``` | `[]` | no |
| default_root_object | The object that you want CloudFront to return when an end user requests the root URL | `string` | `"index.html"` | no |
| force_destroy | Empty bucket contents before deleting S3 bucket | `bool` | `true` | no |
| geo_restriction_locations | The `ISO 3166-1-alpha-2` country codes for which you to either whitelist or blacklist CloudFront content | `list(string)` | `[]` | no |
| geo_restriction_type | The method that you want to use to restrict distribution of your content by country. Possible Values: none, whitelist, or blacklist | `string` | `"none"` | no |
| hosted_zone | Name of hosted zone to add DNS records | `string` | n/a | yes |
| kms_key | Alias/ARN/ID of KMS key for S3 SSE encryption | `string` | `"alias/aws/s3"` | no |
| lambda_functions | A config block that triggers a lambda function with specific actions (maximum 4) ```{ event_type = The specific event to trigger this function. Possible values: viewer-request, origin-request, viewer-response, origin-response lambda_arn = ARN of the Lambda function to trigger upon certain event include_body = When set to true it exposes the request body to the lambda function. Required ONLY for request event }``` | ```list(object({ event_type = string lambda_arn = string include_body = optional(bool) }))``` | `[]` | no |
| origin_path | CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin | `string` | `""` | no |
| price_class | The price class for this distribution. Possible Values: PriceClass_All, PriceClass_200, PriceClass_100 | `string` | `"PriceClass_All"` | no |
| ssl_cert_protocol_version | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Required if using custom certificate. Possible Values: SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016, TLSv1.2_2018, TLSv1.2_2019 or TLSv1.2_2021 | `string` | `"TLSv1.2_2021"` | no |
| ssl_support_method | Specifies how you want CloudFront to serve HTTPS requests. Required if using custom certificate. Possible Values: vip or sni-only | `string` | `"sni-only"` | no |
| tags | Key Value pair to assign to all the resources created by this module | `map(any)` | `{}` | no |
| web_acl_id | For ACL created via WAFv2 provide ACL ARN and for ACL created via WAFv1 provide ACL Id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_arn | ARN of CloudFront distribution created for serving static website |
| cloudfront_endpoint | Endpoint of CloudFront distribution created for serving static website |
| cloudfront_id | ID of CloudFront distribution created for serving static website |
| s3_bucket | ID/Name of S3 bucket created for serving static website |
| s3_bucket_arn | ARN of S3 bucket created for serving static website |
| website_endpoints | Alternate domain names created in Route53 for CloudFront distribution |

<!-- END_TF_DOCS -->
