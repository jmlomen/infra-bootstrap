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
      # --- S3 ---
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      },

      # --- VPC ---
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:DescribeRouteTables",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateTags",
          "ec2:DeleteTags"
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


