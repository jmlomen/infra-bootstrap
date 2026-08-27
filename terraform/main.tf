
# IAM OIDC resource for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]  
}

# Terraform-managed S3 bucket for remote state storage
resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-jmlomen-main"
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_block" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Terraform backend configuration for S3 remote state
terraform {
  backend "s3" {
    bucket         = "tfstate-jmlomen-main"
    key            = "global/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
  }
}


