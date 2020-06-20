# Host a Static Website using S3 & CloudFront

This terraform module will deploy the following services for hosting a static website:
- S3
- CloudFront
- ACM
- Route53

## Licence:
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

MIT Licence. See [Licence](LICENCE) for full details.

# Usage Instructions:
## Variables
| Parameter   | Type   | Description                                                                | Default   | Required |
|-------------|--------|----------------------------------------------------------------------------|-----------|----------|
| profile     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| access_key     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| secret_key     | string | Either profile or access key and secret key is required for creating ACM certificate                                 | null          | N        |
| bucket_name | string | Name of the S3 bucket                                                      |           | Y        |
| origin_path | string | Serve request from a directory within your S3 bucket                  |           | N        |
| cnames      | list   | List of alternate domain names for serving static website                  |          | Y        |
| comment      | string   | Comment to include about distribution                  |          | N        |
| price_class      | string   | The price class for this distribution. Valid values: PriceClass_All, PriceClass_200, PriceClass_100                  | PriceClass_All         | Y        |
| web_acl_id     | string | AWS WAF ACL id to attach to CloudFront distribution                                 | null          | N        |
| hosted_zone | string | Root hosted zone to be used for mapping CloudFront with custom domain name |           | Y        |
| tags | map | A map of tags to assign to the resource  |           | N        |

## Outputs
| Parameter           | Type   | Description               |
|---------------------|--------|---------------------------|
| s3_bucket           | string | S3 Bucket Name            |
| cloudfront_id       | string | ID of CloudFront distribution       |
| cloudfront_endpoint | string | Public endpoint of CloudFront distribution       |
| website_endpoints   | list   | List of website endpoints created. Same as `cnames` variable value  |

## Deployment
- `terraform init` - download plugins required to deploy resources
- `terraform plan` - get detailed view of resources that will be created, deleted or replaced
- `terraform apply -auto-approve` - deploy the template without confirmation (non-interactive mode)
- `terraform destroy -auto-approve` - terminate all the resources created using this template without confirmation (non-interactive mode)
