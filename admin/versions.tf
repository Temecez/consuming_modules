terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
  }

  # Applied once, by hand, from your machine. State stays local for the POC;
  # move it to S3 before anyone else needs to run this.
  backend "local" {
    path = "state/admin.tfstate"
  }
}
