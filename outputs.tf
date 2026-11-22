output "logs_bucket_name" {
  value = module.logs_bucket.bucket_id
}

output "logs_bucket_arn" {
  value = module.logs_bucket.bucket_arn
}

output "logs_bucket_tags" {
  description = "Tags set by the module (provider default_tags are added on top)."
  value       = module.logs_bucket.tags
}
