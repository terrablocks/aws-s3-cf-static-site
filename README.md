# Host a Static Website using S3 & CloudFront

This terraform module will deploy the following services for hosting a static website:
- S3
- CloudFront
- ACM
- Route53 Records

## Licence:
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

MIT Licence. See [Licence](LICENCE) for full details.

# Usage Instructions:
## Example:
```terraform
provider "aws" {
  alias  = "aws.us"
  region = "us-east-1"
}

module "website" {
  source = "github.com/terrablocks/aws-s3-cf-static-site.git"

  profile     = local.profile
  bucket_name = "example-website"
  cnames      = ["example.com"]
  comment     = "Bucket for example website"
  hosted_zone = "example.com"

  providers = {
    aws.us = aws.us
  }
}
```

## Variables
| Parameter   | Type   | Description                                                                | Default   | Required |
|-------------|--------|----------------------------------------------------------------------------|-----------|----------|
| profile     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| access_key     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| secret_key     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| bucket_name | string | Name of the S3 bucket                                                      |           | Y        |
| force_destroy | boolean | Delete all files within the bucket if present before deleting the bucket         | true   | N        |
| origin_path | string | Serve request from a directory within your S3 bucket                  |           | N        |
| cnames      | list   | List of alternate domain names for serving static website                  |          | Y        |
| default_root_object  | string   | Default file to be returned when root URL is requested              | index.html   | N        |
| comment      | string   | Comment to include about distribution                  |          | N        |
| price_class      | string   | The price class for this distribution. Valid values: PriceClass_All, PriceClass_200, PriceClass_100                  | PriceClass_All         | N        |
| geo_restriction_type      | string   | The method that you want to use to restrict distribution of your content by country: `none`, `whitelist`, or `blacklist`      | none         | N        |
| geo_restriction_locations      | list   | The `ISO 3166-1-alpha-2` codes for which you want CloudFront either to `whitelist` or `blacklist` your content      | null        | N        |
| lambda_functions      | list   | List of a map which consists of lambda functions to be associated with CloudFront for edge processing. Scroll below for more details      | []        | N        |
| custom_error_responses      | list   | List of a map which consists of custom error responses to associate with CloudFront. Scroll below for more details      | []        | N        |
| web_acl_id     | string | AWS WAF ACL id to attach to CloudFront distribution                                 | null          | N        |
| hosted_zone | string | Root hosted zone to be used for mapping CloudFront with custom domain name |           | Y        |
| website_domains | list | Map different domain names than domain(s) specified in `cnames` variable for your CloudFront distribution. If left blank domain names provided in `cnames` are used   |           | N        |
| kms_key | string | ID/Alias/ARN of KMS key to use for default server side encryption  |   | N        |
| tags | map | A map of tags to assign to the resource  |           | N        |

## lambda_functions
| Parameter   | Type   | Description                                                                | Default   | Required |
|-------------|--------|----------------------------------------------------------------------------|-----------|----------|
| event_type | string | The specific event to trigger this function. Valid values: `viewer-request`, `origin-request`, `viewer-response`, `origin-response`  |           | N        |
| lambda_arn | string | ARN of the Lambda function  |           | N        |
| include_body | boolean | When set to true it exposes the request body to the lambda function. Valid values: `true`, `false`. **Note:** Required only if event type is of kind request   |           | N        |

## custom_error_responses
| Parameter   | Type   | Description                                                                | Default   | Required |
|-------------|--------|----------------------------------------------------------------------------|-----------|----------|
| error_code | number | The 4xx or 5xx HTTP status code that you want to customize  |           | N        |
| response_code | number | The HTTP status code that you want CloudFront to return with the custom error page to the viewer  |           | N        |
| response_page_path | string | The path of the custom error page. Example: `/custom_404.html`  |           | N        |
| error_caching_ttl | number | The minimum amount of time you want HTTP error codes to stay in CloudFront cache  |           | N        |

## Outputs
| Parameter           | Type   | Description               |
|---------------------|--------|---------------------------|
| s3_bucket           | string | Name of S3 Bucket created for hosting website            |
| s3_bucket_arn       | string | ARN of S3 Bucket created for hosting website            |
| cloudfront_id       | string | ID of CloudFront distribution       |
| cloudfront_arn      | string | ARN of CloudFront distribution       |
| cloudfront_endpoint | string | Public endpoint of CloudFront distribution       |
| website_endpoints   | list   | List of website DNS records created in Route53  |

## Deployment
- `terraform init` - download plugins required to deploy resources
- `terraform plan` - get detailed view of resources that will be created, deleted or replaced
- `terraform apply -auto-approve` - deploy the template without confirmation (non-interactive mode)
- `terraform destroy -auto-approve` - terminate all the resources created using this template without confirmation (non-interactive mode)
