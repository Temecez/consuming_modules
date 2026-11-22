# The endpoint is the account URL (not a secret). The key ID and secret come
# from environment variables so they never land in the repo:
#   SPACELIFT_API_KEY_ID
#   SPACELIFT_API_KEY_SECRET
# Create the key in Spacelift: Organization settings > API keys.
provider "spacelift" {
  api_key_endpoint = "https://temecez.app.us.spacelift.io"
}

# One AWS provider per environment, because each environment's IAM role must
# be created in that environment's account. Profiles are null by default
# (default credential chain); set them in terraform.tfvars when the accounts
# really are separate.
provider "aws" {
  alias   = "dev"
  region  = var.environments["dev"].region
  profile = var.environments["dev"].aws_profile

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias   = "prod"
  region  = var.environments["prod"].region
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
