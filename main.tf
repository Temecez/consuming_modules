data "aws_caller_identity" "current" {}

locals {
  # Bucket names are global; the account ID keeps them unique.
  name_prefix = "temecez-poc-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

# Every module from the aws bundle uses the SAME ref. To upgrade, change it in
# every block (find-and-replace), then run: terraform init -upgrade
# The version is promoted across environments by the pipeline: try it in dev
# from a branch, and stage/prod pick it up once it's merged to main.
module "logs_bucket" {
  source = "git::https://github.com/Temecez/temecez_modules.git//modules/aws/s3-bucket?ref=aws/v1.1.0-rc.2"

  bucket_name   = "${local.name_prefix}-${var.region}"
  force_destroy = var.bucket_force_destroy

  tags = {
    purpose = "logs"
  }
}
