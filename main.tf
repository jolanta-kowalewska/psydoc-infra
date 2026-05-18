module "kms" {
  source      = "./modules/kms"
  environment = var.environment
  project     = var.project
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = var.environment
  project     = var.project
  kms_key_arn = module.kms.key_arn
}

module "s3" {
  source      = "./modules/s3"
  environment = var.environment
  project     = var.project
  kms_key_arn = module.kms.key_arn
}

module "iam" {
  source           = "./modules/iam"
  environment      = var.environment
  project          = var.project
  kms_key_arn      = module.kms.key_arn
  dynamo_table_arn = module.dynamodb.table_arn
  s3_bucket_arn    = module.s3.bucket_arn
}

module "cognito" {
  source      = "./modules/cognito"
  environment = var.environment
  project     = var.project
  kms_key_arn = module.kms.key_arn
}

module "lambda" {
  source          = "./modules/lambda"
  environment     = var.environment
  project         = var.project
  kms_key_arn     = module.kms.key_arn
  cognito_pool_id = module.cognito.user_pool_id
  table_name      = module.dynamodb.table_name
  bucket_name     = module.s3.bucket_name
  lambda_role_arn = module.iam.lambda_role_arn
}

module "api_gateway" {
  source        = "./modules/api_gateway"
  environment   = var.environment
  project       = var.project
  function_arns = module.lambda.function_arns
  user_pool_arn = module.cognito.user_pool_arn
}