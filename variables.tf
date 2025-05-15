variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID for the domain"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names for the SSL certificate"
  type        = list(string)
  default     = []
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cors_rules" {
  description = "List of CORS rules for the S3 bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
