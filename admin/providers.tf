# The endpoint is the account URL (not a secret). The key ID and secret come
# from environment variables so they never land in the repo:
#   SPACELIFT_API_KEY_ID
#   SPACELIFT_API_KEY_SECRET
# Create the key in Spacelift: Organization settings > API keys.
provider "spacelift" {
  api_key_endpoint = "https://temecez.app.us.spacelift.io"
}

# One AWS provider per environment (= AWS account), used only to create that
# account's Spacelift role. IAM is global, so the region here doesn't matter.
#
# Today every environment uses the same account (aws_profile = null, the
# default credential chain). When environments become separate accounts, give
# each one a profile in var.environments, or replace `profile` with:
#   assume_role {
#     role_arn = "arn:aws:iam::<account-id>:role/OrganizationAccountAccessRole"
#   }
provider "aws" {
  alias   = "dev"
  region  = "us-east-1"
  profile = var.environments["dev"].aws_profile

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias   = "prod"
  region  = "us-east-1"
  profile = var.environments["prod"].aws_profile

  default_tags {
    tags = local.default_tags
  }
}

locals {
  default_tags = {
    managed_by = "terraform"
    repo       = "consuming_modules"
    component  = "spacelift-admin"
  }
}
