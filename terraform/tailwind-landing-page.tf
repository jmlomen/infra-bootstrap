resource "aws_iam_role" "github_terraform_deploy" {
  name = "TailwindLandingPageDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # IMPORTANT: restrict to your repo
            "token.actions.githubusercontent.com:sub" = "repo:jmlomen@*/tailwind-landing-page-template@*:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_minimal" {
  name        = "TerraformMinimalPermissions"
  description = "Minimal permissions for Terraform backend + read-only IAM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # --- S3 Backend ---
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.tfstate.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.tfstate.arn}/*"
      },

      # --- Read-only IAM (safe + recommended) ---
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      },

      # --- Applications may require additional permissions, e.g. for S3, CloudFront, etc. ---
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",          
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_minimal_attach" {
  role       = aws_iam_role.github_terraform_deploy.name
  policy_arn = aws_iam_policy.terraform_minimal.arn
}


