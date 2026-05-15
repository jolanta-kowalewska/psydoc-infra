terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "psydoc-tfstate-708037416948"
    key            = "psydoc/dev/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "psydoc-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}