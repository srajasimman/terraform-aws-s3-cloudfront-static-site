locals {
  s3_origin_id = "S3-${var.bucket_name}"
}

# Generate random suffix for bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for website hosting
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "${var.bucket_name}-${random_string.bucket_suffix.result}"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule = var.cors_rules

  tags = var.tags
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "OAI for ${var.domain_name}"
}

# S3 bucket policy
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# ACM Certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = var.domain_name
  zone_id                   = var.route53_zone_id
  subject_alternative_names = var.subject_alternative_names
  wait_for_validation       = true

  tags = var.tags

  providers = {
    aws = aws.us-east-1
  }
}

# CloudFront distribution
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.0"

  aliases = concat([var.domain_name], var.subject_alternative_names)

  comment             = "CloudFront distribution for ${var.domain_name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.cloudfront_price_class
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = false
  origin_access_identities = {
    s3_bucket = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
  }

  origin = {
    s3_bucket = {
      domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  custom_error_response = [{
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }]

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}
