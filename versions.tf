terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Settings come from envs/<env>.tfbackend at init time:
  #   terraform init -reconfigure -backend-config=envs/dev.tfbackend
  #
  # Local state for the POC. At enterprise scale, switch to:
  #   backend "s3" {}
  # and put bucket/key/region/use_lockfile in each envs/<env>.tfbackend.
  backend "local" {}
}
