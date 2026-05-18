locals {
  functions = {
    "clients-create"   = { handler = "clients.create", timeout = 10, memory = 256 }
    "clients-get"      = { handler = "clients.get", timeout = 10, memory = 256 }
    "sessions-create"  = { handler = "sessions.create", timeout = 15, memory = 256 }
    "sessions-sign"    = { handler = "sessions.sign", timeout = 30, memory = 512 }
    "consents-create"  = { handler = "consents.create", timeout = 15, memory = 256 }
    "documents-export" = { handler = "documents.export", timeout = 30, memory = 512 }
  }
}

data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "# placeholder — deploy przez GitHub Actions"
    filename = "handler.py"
  }
}


resource "aws_lambda_function" "functions" {
  for_each = local.functions

  function_name = "${var.project}-${var.environment}-${each.key}"
  role          = var.lambda_role_arn
  runtime       = "python3.12"
  handler       = each.value.handler
  timeout       = each.value.timeout
  memory_size   = each.value.memory

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE  = var.table_name
      S3_BUCKET       = var.bucket_name
      KMS_KEY_ARN     = var.kms_key_arn
      COGNITO_POOL_ID = var.cognito_pool_id
      ENVIRONMENT     = var.environment
    }
  }
}