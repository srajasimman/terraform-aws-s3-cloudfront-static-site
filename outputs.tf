output "s3_bucket_id" {
  description = "The name of the bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "acm_certificate_status" {
  description = "Status of the certificate"
  value       = module.acm.acm_certificate_status
}

output "full_bucket_name" {
  description = "The full name of the S3 bucket including the random suffix"
  value       = module.s3_bucket.s3_bucket_id
}
