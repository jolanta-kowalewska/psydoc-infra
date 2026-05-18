variable "environment" {
  description = "The environment to deploy resources into."
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "user_pool_arn" {
  description = "Cognito user pool ARN"
  type        = string
}

variable "function_arns" {
  description = "Lambda functions ARNs (map)"
  type        = map(string)
}