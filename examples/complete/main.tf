provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "static_website" {
  source = "../../"

  bucket_name     = "my-static-website-bucket-2025"
  domain_name     = "example.com"
  route53_zone_id = "Z1234567890ABC"

  subject_alternative_names = ["www.example.com"]

  cloudfront_price_class = "PriceClass_100"

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com", "https://www.example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  ]

  tags = {
    Environment = "Production"
    Terraform   = "true"
  }

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
