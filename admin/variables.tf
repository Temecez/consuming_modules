variable "repository" {
  description = "GitHub repository (name only) the stacks run."
  type        = string
  default     = "consuming_modules"
}

variable "environments" {
  description = "Per-environment settings. Adding an environment also needs a provider alias and module block (providers can't be looped over)."
  type = map(object({
    region      = string
    aws_profile = optional(string)
    autodeploy  = optional(bool, false)
  }))

  default = {
    dev  = { region = "us-east-2" }
    prod = { region = "us-east-1" }
  }
}

variable "role_policy_arns" {
  description = "IAM policies attached to every stack's role. PowerUserAccess can't manage IAM; add IAM permissions if a stack needs them."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}
