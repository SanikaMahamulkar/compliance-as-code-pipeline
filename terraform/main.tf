terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  # Skip validation calls to real AWS - this project only ever runs
  # `terraform plan`, never `apply`, so no real AWS account is needed.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# COMPLIANT: encrypted, versioned, no public access
resource "aws_s3_bucket" "compliant_data" {
  bucket = "example-compliant-data-bucket"
}

resource "aws_s3_bucket_versioning" "compliant_data" {
  bucket = aws_s3_bucket.compliant_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compliant_data" {
  bucket = aws_s3_bucket.compliant_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "compliant_data" {
  bucket                  = aws_s3_bucket.compliant_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# NON-COMPLIANT: no encryption, no versioning, no public access block
resource "aws_s3_bucket" "noncompliant_data" {
  bucket = "example-noncompliant-data-bucket"
}
