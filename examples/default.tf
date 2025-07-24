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
