# Deployment: dev environment (AWS account) in us-east-1.
environment          = "dev"
region               = "us-east-1"
bucket_force_destroy = true # dev only: lets `terraform destroy` remove non-empty buckets
