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
| profile     | string | AWS profile to be used for AuthN and AuthZ                                 |           | Y        |
| region      | string | AWS region identifier where resources needs to be created                  | us-east-1 | N        |
| bucket_name | string | Name of the S3 bucket                                                      |           | Y        |
| cnames      | list   | List of alternate domain names for serving static website                  |           | Y        |
| hosted_zone | string | Root hosted zone to be used for mapping CloudFront with custom domain name |           | Y        |

## Outputs
| Parameter           | Type   | Description               |
|---------------------|--------|---------------------------|
| s3_bucket           | string | S3 Bucket Name            |
| cloudfront_endpoint | string | CloudFront endpoint       |
| website_endpoint    | string | Primary website endpoint  |

## Deployment
- `terraform init` - download plugins required to deploy resources
- `terraform plan` - get detailed view of resources that will be created, deleted or replaced
- `terraform apply -auto-approve` - deploy the template without confirmation (non-interactive mode)
- `terraform destroy -auto-approve` - terminate all the resources created using this template without confirmation (non-interactive mode)
