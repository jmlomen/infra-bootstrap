# infra-bootstrap
Infrastructure Bootstrap Repo


# 🥇 Best practice architecture

This Repo — infra-bootstrap (Platform / Identity / Foundation)

This repo is run manually or by a protected pipeline.

It creates:

- GitHub OIDC provider

- GithubTerraformDeployRole

- S3 backend bucket

- DynamoDB lock table

- Minimal IAM policy for Terraform

- Any org‑level IAM/SCP/billing resources

This repo rarely changes.

## Usage

### In order to manage the ***GithubTerraformDeployRole*** 
1) Create it manually
2) Import it into terraform state after terraform state & s3 bucket have been setup