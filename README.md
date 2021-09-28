# Host a Static Website using S3 & CloudFront

![License](https://img.shields.io/github/license/terrablocks/aws-s3-cf-static-site?style=for-the-badge) ![Tests](https://img.shields.io/github/workflow/status/terrablocks/aws-s3-cf-static-site/tests/master?label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/workflow/status/terrablocks/aws-s3-cf-static-site/checkov/master?label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-s3-cf-static-site?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-s3-cf-static-site?style=for-the-badge)

This terraform module will deploy the following services for hosting a static website:
- S3
- CloudFront
- ACM
- Route53 Records

# Usage Instructions
## Example
```terraform
module "website" {
  source = "github.com/terrablocks/aws-s3-cf-static-site.git"

  profile     = ""
  bucket_name = "example-website"
  cnames      = ["example.com"]
  comment     = "Bucket for example website"
  hosted_zone = "example.com"

  providers = {
    aws.us = aws.us
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| aws | >= 3.37.0 |
| random | >= 3.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of S3 bucket | `string` | n/a | yes |
| bucket_policy | Resource policy to apply on S3 bucket. Leave it blank to generate one automatically | `string` | `""` | no |
| force_destroy | Empty bucket contents before deleting S3 bucket | `bool` | `true` | no |
| kms_key | Alias/ARN/ID of KMS key for S3 SSE encryption | `string` | `"alias/aws/s3"` | no |
| origin_path | CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin | `string` | `""` | no |
| default_root_object | The object that you want CloudFront to return when an end user requests the root URL | `string` | `"index.html"` | no |
| cnames | Access CloudFront using alternate domain names, if any | `list(string)` | `[]` | no |
| web_acl_id | For ACL created via WAFv2 provide ACL ARN and for ACL created via WAFv1 provide ACL Id | `string` | `null` | no |
| lambda_functions | A config block that triggers a lambda function with specific actions (maximum 4)<pre>{<br>  event_type   = The specific event to trigger this function. Possible values: viewer-request, origin-request, viewer-response, origin-response<br>  lambda_arn   = ARN of the Lambda function to trigger upon certain event<br>  include_body = When set to true it exposes the request body to the lambda function. Required ONLY for request event<br>}</pre> | <pre>list(object({<br>    event_type   = string<br>    lambda_arn   = string<br>    include_body = optional(bool)<br>  }))</pre> | `[]` | no |
| cloudfront_functions | A config block that triggers a CloudFront function with specific actions (maximum 2)<pre>{<br>  event_type = The specific event to trigger this function. Possible values: viewer-request, viewer-response<br>  function_arn = ARN of the CloudFront function to trigger upon certain event<br>}</pre> | <pre>list(object({<br>    event_type   = string<br>    function_arn = string<br>  }))</pre> | `[]` | no |
| price_class | The price class for this distribution. Possible Values: PriceClass_All, PriceClass_200, PriceClass_100 | `string` | `"PriceClass_All"` | no |
| ssl_support_method | Specifies how you want CloudFront to serve HTTPS requests. Required if using custom certificate. Possible Values: vip or sni-only | `string` | `"sni-only"` | no |
| ssl_cert_protocol_version | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Required if using custom certificate. Possible Values: SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016, TLSv1.2_2018 or TLSv1.2_2019 | `string` | `"TLSv1.2_2019"` | no |
| geo_restriction_type | The method that you want to use to restrict distribution of your content by country. Possible Values: none, whitelist, or blacklist | `string` | `"none"` | no |
| geo_restriction_locations | The `ISO 3166-1-alpha-2` country codes for which you to either whitelist or blacklist CloudFront content | `list(string)` | `[]` | no |
| custom_error_responses | One or more custom error response elements (multiples allowed)<pre>{<br>  error_caching_min_ttl = The minimum amount of time you want HTTP error codes to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated<br>  error_code            = The 4xx or 5xx HTTP status code that you want to customize<br>  response_code         = The HTTP status code that you want CloudFront to return with the custom error page to the viewer<br>  response_page_path    = The path of the custom error page. Example: /404.html. Make sure the file 404.html is present within the origin<br>}</pre> | <pre>list(object({<br>    error_code            = number<br>    error_caching_min_ttl = optional(number)<br>    response_code         = optional(number)<br>    response_page_path    = optional(string)<br>  }))</pre> | `[]` | no |
| access_logging | The logging configuration that controls how logs are written to your distribution<pre>{<br>  bucket          = The Amazon S3 bucket to store the access logs in. Example: bucketname.s3.amazonaws.com<br>  include_cookies = Specifies whether you want CloudFront to include cookies in access logs<br>  prefix          = An optional string that you want CloudFront to prefix to the access log filenames for this distribution<br>}</pre> | <pre>object({<br>    bucket          = string<br>    include_cookies = optional(bool)<br>    prefix          = optional(string)<br>  })</pre> | `null` | no |
| tags | Key Value pair to assign to CloudFront and S3 bucket | `map(any)` | `{}` | no |
| comment | Description/Comments about distribution | `string` | `"Managed by terrablocks"` | no |
| hosted_zone | Name of hosted zone to add DNS records if `cnames` are provided | `string` | `null` | no |
| website_domains | Map different domain names than domain(s) specified in `cnames` variable for your CloudFront distribution. If left blank domain names provided in `cnames` are used | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket | ID/Name of S3 bucket created for serving static website |
| s3_bucket_arn | ARN of S3 bucket created for serving static website |
| cloudfront_id | ID of CloudFront distribution created for serving static website |
| cloudfront_arn | ARN of CloudFront distribution created for serving static website |
| cloudfront_endpoint | Endpoint of CloudFront distribution created for serving static website |
| website_endpoints | Alternate domain names created in Route53 for CloudFront distribution |
