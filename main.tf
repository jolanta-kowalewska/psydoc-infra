module "kms" {
  source      = "./modules/kms"
  environment = var.environment
  project     = var.project
}

