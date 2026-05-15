module "kms" {
  source      = "./modules/kms"
  environment = var.environment
  project     = var.project
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = var.environment
  project     = var.project
  key_arn     = module.kms.key_arn
}