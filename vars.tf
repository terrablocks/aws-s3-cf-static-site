variable "profile" {
  default = null
}

variable "access_key" {
  default = null
}

variable "secret_key" {
  default = null
}

variable "bucket_name" {}

variable "force_destroy" {
  default = true
}

variable "origin_path" {
  default = ""
}

variable "cnames" {
  type = list(any)
}

variable "default_root_object" {
  default = "index.html"
}

variable "hosted_zone" {}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "comment" {
  default = "Managed by terrablocks"
}

variable "price_class" {
  default = "PriceClass_All"
}

variable "geo_restriction_type" {
  default = "none"
}

variable "geo_restriction_locations" {
  type    = list(any)
  default = null
}

variable "lambda_functions" {
  type    = list(any)
  default = []
}

variable "custom_error_responses" {
  type    = list(any)
  default = []
}

variable "web_acl_id" {
  default = null
}

variable "website_domains" {
  type    = list(any)
  default = []
}

variable "kms_key" {
  default = ""
}
