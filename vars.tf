variable "profile" {}
variable "region" {
  default = "us-east-1"
}
variable "bucket_name" {}
variable "cnames" {
  type = "list"
}
variable "hosted_zone" {}
