module "kms" {
  source      = "./modules/kms"
  environment = var.environment
  project     = var.project
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = var.environment
  project     = var.project
  kms_key_arn     = module.kms.key_arn
}

module "s3" {
  source = "./modules/s3"
  environment = var.environment
  project     = var.project
  kms_key_arn     = module.kms.key_arn
}
