output "stacks" {
  description = "Stack ID per deployment."
  value       = { for k, s in module.stacks : k => s.stack_id }
}

output "integration_ids" {
  description = "Spacelift AWS integration ID per environment (account)."
  value       = local.integration_ids
}

output "role_arns" {
  description = "Spacelift IAM role ARN per environment (account)."
  value = {
    dev  = module.dev_role.role_arn
    prod = module.prod_role.role_arn
  }
}
