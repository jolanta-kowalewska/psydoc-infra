variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "The environment to deploy resources into."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Allowed values: dev, staging, prod."
  }
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "psydoc"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "psydoc-infra"
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = "jolanta-kowalewska"
}