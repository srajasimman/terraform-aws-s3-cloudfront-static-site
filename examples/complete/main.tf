provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

locals {
  domain_name = "example.com"
  bucket_name = "${replace(local.domain_name, ".", "-")}-website"
}

data "aws_route53_zone" "zone" {
  name         = local.domain_name
  private_zone = false
}

module "static_website" {
  source = "../../"

  bucket_name     = local.bucket_name
  domain_name     = local.domain_name
  route53_zone_id = data.aws_route53_zone.zone.zone_id

  subject_alternative_names = ["www.${local.domain_name}"]

  cloudfront_price_class = "PriceClass_100"

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://${local.domain_name}", "https://www.${local.domain_name}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  ]

  tags = {
    Environment = "Production"
    Terraform   = "true"
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
