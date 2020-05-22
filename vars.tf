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

variable "origin_path" {
  default = ""
}

variable "cnames" {
  type = list
}

variable "hosted_zone" {}
