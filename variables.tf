variable "environment" {
  description = "Environment name (dev, stage, prod). Used in names and tags."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile for this environment's account. null uses the default credential chain."
  type        = string
  default     = null
}

variable "bucket_force_destroy" {
  description = "Allow destroying buckets that still contain objects. true only in non-prod."
  type        = bool
  default     = false
}
