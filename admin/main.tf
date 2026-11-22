# Spacelift setup for this repo.
#
#   environment (= AWS account): one integration + one IAM role, shared
#   deployment  (= environment + region): one stack, using its environment's integration
#
# Order matters:
#   - the integration needs the role ARN, so the ARN is built from the role name
#   - the role's trust policy needs the integration ID
#   - attaching an integration to a stack tests the role, so stacks wait for the roles
#
# Every module from a bundle uses the SAME ref. To upgrade, change it in every
# block of that bundle, then run: terraform init -upgrade

# ================================================================ environments

data "aws_caller_identity" "dev" {
  provider = aws.dev
}

data "aws_caller_identity" "prod" {
  provider = aws.prod
}

locals {
  role_names = {
    dev  = "spacelift-dev"
    prod = "spacelift-prod"
  }
  role_arns = {
    dev  = "arn:aws:iam::${data.aws_caller_identity.dev.account_id}:role/${local.role_names.dev}"
    prod = "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:role/${local.role_names.prod}"
  }
  integration_ids = {
    dev  = module.dev_integration.id
    prod = module.prod_integration.id
  }
}

# ---------------------------------------------------------------- dev account

module "dev_integration" {
  source    = "git::https://github.com/Temecez/temecez_modules.git//modules/spacelift/aws-integration?ref=spacelift/v1.1.0"
  providers = { spacelift = spacelift }

  name     = "aws-dev"
  role_arn = local.role_arns.dev
  labels   = ["env:dev"]
}

module "dev_role" {
  source    = "git::https://github.com/Temecez/temecez_modules.git//modules/aws/spacelift-role?ref=aws/v1.2.0"
  providers = { aws = aws.dev }

  name                     = local.role_names.dev
  spacelift_account_name   = var.spacelift_account_name
  spacelift_aws_account_id = var.spacelift_aws_account_id
  integration_id           = module.dev_integration.id
  role_policy_arns         = var.role_policy_arns
}

# ---------------------------------------------------------------- prod account

module "prod_integration" {
  source    = "git::https://github.com/Temecez/temecez_modules.git//modules/spacelift/aws-integration?ref=spacelift/v1.1.0"
  providers = { spacelift = spacelift }

  name     = "aws-prod"
  role_arn = local.role_arns.prod
  labels   = ["env:prod"]
}

module "prod_role" {
  source    = "git::https://github.com/Temecez/temecez_modules.git//modules/aws/spacelift-role?ref=aws/v1.2.0"
  providers = { aws = aws.prod }

  name                     = local.role_names.prod
  spacelift_account_name   = var.spacelift_account_name
  spacelift_aws_account_id = var.spacelift_aws_account_id
  integration_id           = module.prod_integration.id
  role_policy_arns         = var.role_policy_arns
}

# ================================================================ deployments

module "stacks" {
  source    = "git::https://github.com/Temecez/temecez_modules.git//modules/spacelift/stack?ref=spacelift/v1.1.0"
  providers = { spacelift = spacelift }
  for_each  = var.deployments

  name                = "${var.repository}-${each.key}"
  description         = "${var.repository} (${each.value.environment}, ${each.value.region}), managed by admin/"
  repository          = var.repository
  labels              = ["env:${each.value.environment}", "region:${each.value.region}"]
  var_file            = "envs/${each.value.environment}/${each.value.region}.tfvars"
  autodeploy          = var.environments[each.value.environment].autodeploy
  aws_integration_ids = { aws = local.integration_ids[each.value.environment] }
  context_ids         = { github = var.github_modules_context_id }

  depends_on = [module.dev_role, module.prod_role]
}
