# One-time migration from the deprecated spacelift/aws-stack module (one
# module per environment) to the split modules. `moved` keeps the existing
# stacks, and their Spacelift-managed state, instead of destroying and
# recreating them. Safe to delete this file after the migration is applied.
#
# The old dev stack becomes dev-us-east-2 and the old prod stack becomes
# prod-us-east-1. Renaming a stack keeps its ID, so their IDs stay
# consuming_modules-dev / consuming_modules-prod.

# ---------------------------------------------------------------- dev -> dev-us-east-2 + dev account

moved {
  from = module.dev.spacelift_stack.this
  to   = module.stacks["dev-us-east-2"].spacelift_stack.this
}

moved {
  from = module.dev.spacelift_environment_variable.this
  to   = module.stacks["dev-us-east-2"].spacelift_environment_variable.this
}

moved {
  from = module.dev.spacelift_aws_integration_attachment.this
  to   = module.stacks["dev-us-east-2"].spacelift_aws_integration_attachment.this["aws"]
}

moved {
  from = module.dev.spacelift_aws_integration.this
  to   = module.dev_integration.spacelift_aws_integration.this
}

moved {
  from = module.dev.aws_iam_role.this
  to   = module.dev_role.aws_iam_role.this
}

moved {
  from = module.dev.aws_iam_role_policy_attachment.this
  to   = module.dev_role.aws_iam_role_policy_attachment.this
}

# The github-modules-read context was attached to the dev stack by hand in the
# Spacelift UI. Import that attachment instead of creating a duplicate.
import {
  to = module.stacks["dev-us-east-2"].spacelift_context_attachment.this["github"]
  id = "${var.github_modules_context_id}/${var.repository}-dev"
}

# ---------------------------------------------------------------- prod -> prod-us-east-1 + prod account

moved {
  from = module.prod.spacelift_stack.this
  to   = module.stacks["prod-us-east-1"].spacelift_stack.this
}

moved {
  from = module.prod.spacelift_environment_variable.this
  to   = module.stacks["prod-us-east-1"].spacelift_environment_variable.this
}

moved {
  from = module.prod.spacelift_aws_integration_attachment.this
  to   = module.stacks["prod-us-east-1"].spacelift_aws_integration_attachment.this["aws"]
}

moved {
  from = module.prod.spacelift_aws_integration.this
  to   = module.prod_integration.spacelift_aws_integration.this
}

moved {
  from = module.prod.aws_iam_role.this
  to   = module.prod_role.aws_iam_role.this
}

moved {
  from = module.prod.aws_iam_role_policy_attachment.this
  to   = module.prod_role.aws_iam_role_policy_attachment.this
}
