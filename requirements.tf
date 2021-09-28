terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
      # configuration_aliases = [aws.us]  # bug: https://github.com/hashicorp/terraform/issues/28490
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  experiments = [module_variable_optional_attrs]
}
