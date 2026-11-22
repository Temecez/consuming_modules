terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # No backend block: Spacelift manages state for each stack and injects its
  # own backend at run time (state-credentials.tf). Declaring one here causes
  # "Duplicate backend configuration".
}
