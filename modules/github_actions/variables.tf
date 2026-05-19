variable "environment" {
  description = "The environment to deploy resources into."
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "github_repo" {
  description = "The github repository name for this project"
  type        = string
}


variable "github_username" {
  description = "The github repository username owner"
  type        = string
}