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

variable "table_name" {
  description = "The project and environment DynamoDB table name"
  type        = string
}

variable "bucket_name" {
  description = "The project and environment S3 bucket Documents arn"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda role with required permissions"
  type        = string
}

variable "cognito_pool_id" {
  description = "Cognito pool id to login authorized user"
  type        = string
}

