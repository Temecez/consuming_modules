output "stacks" {
  value = {
    dev  = module.dev.stack_id
    prod = module.prod.stack_id
  }
}

output "role_arns" {
  value = {
    dev  = module.dev.role_arn
    prod = module.prod.role_arn
  }
}
