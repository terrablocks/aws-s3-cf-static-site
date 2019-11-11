# Host a Static Website using S3 & CloudFront

This terraform module will deploy the following services for hosting a static website:
- S3
- CloudFront
- ACM
- Route53

# Usage Instructions:
## Variable Initialization
- **profile**: AWS profile to be used for AuthN and AuthZ
- **region**: AWS region identifier where resources needs to be created
- **bucket_name**: Name of the S3 bucket
- **cnames**: List of alternate domain names for serving static website
- **hosted_zone**: Root hosted zone to be used for mapping CloudFront with custom domain name

## Deployment
- `terraform init` - initializes plugins required to deploy resources
- `terraform plan` - get detailed view of resources being created/deleted/replaced
- `terraform apply -auto-approve` - deploy the template