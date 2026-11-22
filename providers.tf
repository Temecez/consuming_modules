provider "aws" {
  region = var.region

  # Each environment usually lives in its own AWS account; pick its
  # credentials with a named profile (or replace with assume_role).
  profile = var.aws_profile

  # Baseline tags for EVERY AWS resource in this configuration, whether it comes
  # from a shared module or a plain aws_* resource. Modules can add stricter
  # tags of their own (the s3-bucket module forces infra = "true").
  default_tags {
    tags = {
      infra       = "true"
      managed_by  = "terraform"
      environment = var.environment
      repo        = "consuming_modules"
    }
  }
}
