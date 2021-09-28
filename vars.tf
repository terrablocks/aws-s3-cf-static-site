variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket"
}

variable "bucket_policy" {
  type        = string
  default     = ""
  description = "Resource policy to apply on S3 bucket. Leave it blank to generate one automatically"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Empty bucket contents before deleting S3 bucket"
}

variable "kms_key" {
  type        = string
  default     = "alias/aws/s3"
  description = "Alias/ARN/ID of KMS key for S3 SSE encryption"
}

variable "origin_path" {
  type        = string
  default     = ""
  description = "CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "The object that you want CloudFront to return when an end user requests the root URL"
}

variable "cnames" {
  type        = list(string)
  default     = []
  description = "Access CloudFront using alternate domain names, if any"
}

variable "web_acl_id" {
  type        = string
  default     = null
  description = "For ACL created via WAFv2 provide ACL ARN and for ACL created via WAFv1 provide ACL Id"
}

variable "lambda_functions" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool)
  }))
  default     = []
  description = <<-EOT
    A config block that triggers a lambda function with specific actions (maximum 4)
    ```{
      event_type   = The specific event to trigger this function. Possible values: viewer-request, origin-request, viewer-response, origin-response
      lambda_arn   = ARN of the Lambda function to trigger upon certain event
      include_body = When set to true it exposes the request body to the lambda function. Required ONLY for request event
    }```
  EOT
}

variable "cloudfront_functions" {
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default     = []
  description = <<-EOT
    A config block that triggers a CloudFront function with specific actions (maximum 2)
    ```{
      event_type = The specific event to trigger this function. Possible values: viewer-request, viewer-response
      function_arn = ARN of the CloudFront function to trigger upon certain event
    }```
  EOT
}

variable "price_class" {
  type        = string
  default     = "PriceClass_All"
  description = "The price class for this distribution. Possible Values: PriceClass_All, PriceClass_200, PriceClass_100"
}

variable "ssl_support_method" {
  type        = string
  default     = "sni-only"
  description = "Specifies how you want CloudFront to serve HTTPS requests. Required if using custom certificate. Possible Values: vip or sni-only"
}

variable "ssl_cert_protocol_version" {
  type        = string
  default     = "TLSv1.2_2019"
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. Required if using custom certificate. Possible Values: SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016, TLSv1.2_2018 or TLSv1.2_2019"
}

variable "geo_restriction_type" {
  type        = string
  default     = "none"
  description = "The method that you want to use to restrict distribution of your content by country. Possible Values: none, whitelist, or blacklist"
}

variable "geo_restriction_locations" {
  type        = list(string)
  default     = []
  description = "The `ISO 3166-1-alpha-2` country codes for which you to either whitelist or blacklist CloudFront content"
}

variable "custom_error_responses" {
  type = list(object({
    error_code            = number
    error_caching_min_ttl = optional(number)
    response_code         = optional(number)
    response_page_path    = optional(string)
  }))
  default     = []
  description = <<-EOT
    One or more custom error response elements (multiples allowed)
    ```{
      error_caching_min_ttl = The minimum amount of time you want HTTP error codes to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated
      error_code            = The 4xx or 5xx HTTP status code that you want to customize
      response_code         = The HTTP status code that you want CloudFront to return with the custom error page to the viewer
      response_page_path    = The path of the custom error page. Example: /404.html. Make sure the file 404.html is present within the origin
    }```
  EOT
}

variable "access_logging" {
  type = object({
    bucket          = string
    include_cookies = optional(bool)
    prefix          = optional(string)
  })
  default     = null
  description = <<-EOT
    The logging configuration that controls how logs are written to your distribution
    ```{
      bucket          = The Amazon S3 bucket to store the access logs in. Example: bucketname.s3.amazonaws.com
      include_cookies = Specifies whether you want CloudFront to include cookies in access logs
      prefix          = An optional string that you want CloudFront to prefix to the access log filenames for this distribution
    }```
  EOT
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Key Value pair to assign to CloudFront and S3 bucket"
}

variable "comment" {
  type        = string
  default     = "Managed by terrablocks"
  description = "Description/Comments about distribution"
}

variable "hosted_zone" {
  type        = string
  default     = null
  description = "Name of hosted zone to add DNS records if `cnames` are provided"
}

variable "website_domains" {
  type        = list(string)
  default     = []
  description = "Map different domain names than domain(s) specified in `cnames` variable for your CloudFront distribution. If left blank domain names provided in `cnames` are used"
}
