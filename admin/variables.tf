variable "repository" {
  description = "GitHub repository (name only) the stacks run."
  type        = string
  default     = "consuming_modules"
}

# An environment IS an AWS account: it gets one Spacelift role and one
# integration, shared by every deployment (region) in it. Adding an environment
# also needs a provider alias and role/integration blocks (providers can't be
# looped over).
variable "environments" {
  description = "Environments (AWS accounts). aws_profile selects the account's credentials; null uses the default chain."
  type = map(object({
    aws_profile = optional(string)
    autodeploy  = optional(bool, false)
  }))

  default = {
    dev  = {}
    prod = {}
  }
}

# A deployment is an environment in one region: it gets one Spacelift stack,
# which runs the repo with envs/<environment>/<region>.tfvars.
variable "deployments" {
  description = "Deployments as { key = { environment, region } }. The key is used in the stack name."
  type = map(object({
    environment = string
    region      = string
  }))

  default = {
    "dev-us-east-2"  = { environment = "dev", region = "us-east-2" }
    "dev-us-east-1"  = { environment = "dev", region = "us-east-1" }
    "prod-us-east-1" = { environment = "prod", region = "us-east-1" }
  }

  validation {
    condition     = alltrue([for d in values(var.deployments) : contains(keys(var.environments), d.environment)])
    error_message = "Every deployment's environment must be a key in var.environments."
  }
}

variable "role_policy_arns" {
  description = "IAM policies attached to each account's Spacelift role. PowerUserAccess can't manage IAM; add IAM permissions if a stack needs them."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "spacelift_account_name" {
  description = "Spacelift account name as it appears in external IDs (case-sensitive)."
  type        = string
  default     = "Temecez"
}

variable "spacelift_aws_account_id" {
  description = "Spacelift's AWS account that assumes the roles. 577638371743 is the US region (app.us.spacelift.io)."
  type        = string
  default     = "577638371743"
}

variable "github_modules_context_id" {
  description = "Spacelift context (created in the UI) holding the GitHub token that lets stacks download private modules."
  type        = string
  default     = "github-modules-read"
}
