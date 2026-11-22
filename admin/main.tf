# One Spacelift stack per environment, from the shared spacelift/aws-stack module.
# Both providers are passed explicitly: with a `providers` map, the module only
# receives the providers listed.
#
# Every module from the spacelift bundle uses the SAME ref. To upgrade, change
# it in every block, then run: terraform init -upgrade

module "dev" {
  source = "git::https://github.com/Temecez/temecez_modules.git//modules/spacelift/aws-stack?ref=spacelift/v1.0.0"
  providers = {
    aws       = aws.dev
    spacelift = spacelift
  }

  name             = "${var.repository}-dev"
  description      = "${var.repository} (dev), managed by admin/"
  repository       = var.repository
  labels           = ["env:dev"]
  var_file         = "envs/dev.tfvars"
  autodeploy       = var.environments["dev"].autodeploy
  role_policy_arns = var.role_policy_arns
}

module "prod" {
  source = "git::https://github.com/Temecez/temecez_modules.git//modules/spacelift/aws-stack?ref=spacelift/v1.0.0"
  providers = {
    aws       = aws.prod
    spacelift = spacelift
  }

  name             = "${var.repository}-prod"
  description      = "${var.repository} (prod), managed by admin/"
  repository       = var.repository
  labels           = ["env:prod"]
  var_file         = "envs/prod.tfvars"
  autodeploy       = var.environments["prod"].autodeploy
  role_policy_arns = var.role_policy_arns
}
