variable "environment" {
  description = "The environment to deploy resources into."
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "kms_key_arn" {
  description = "The project and environment key ARN of KMS"
  type        = string
}