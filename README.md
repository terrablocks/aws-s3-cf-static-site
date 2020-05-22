# Host a Static Website using S3 & CloudFront

This terraform module will deploy the following services for hosting a static website:
- S3
- CloudFront
- ACM
- Route53

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
| hosted_zone | string | Root hosted zone to be used for mapping CloudFront with custom domain name |           | Y        |

## Outputs
| Parameter           | Type   | Description               |
|---------------------|--------|---------------------------|
| s3_bucket           | string | S3 Bucket Name            |
| cloudfront_arn      | string | ARN of CloudFront distribution       |
| cloudfront_endpoint | string | Public endpoint of CloudFront distribution       |
| website_endpoints   | list   | List of website endpoints created. Same as `cnames` variable value  |

## Deployment
- `terraform init` - download plugins required to deploy resources
- `terraform plan` - get detailed view of resources that will be created, deleted or replaced
- `terraform apply -auto-approve` - deploy the template without confirmation (non-interactive mode)
- `terraform destroy -auto-approve` - terminate all the resources created using this template without confirmation (non-interactive mode)
