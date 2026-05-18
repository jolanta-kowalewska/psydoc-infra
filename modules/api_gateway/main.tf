data "aws_region" "current" {}

locals {
  lambda_uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions"
}


resource "aws_api_gateway_rest_api" "psydoc" {
  name        = "${var.project}-${var.environment}"
  description = "PsyDoc API — dokumentacja psychologiczna"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.user_pool_arn]

  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "clients" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_rest_api.psydoc.root_resource_id
  path_part   = "clients"
}

resource "aws_api_gateway_resource" "client_id" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.clients.id
  path_part   = "{clientId}"
}

resource "aws_api_gateway_resource" "consents" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.client_id.id
  path_part   = "consents"
}

resource "aws_api_gateway_resource" "groups" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_rest_api.psydoc.root_resource_id
  path_part   = "groups"
}

resource "aws_api_gateway_resource" "group_id" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.groups.id
  path_part   = "{groupId}"
}

resource "aws_api_gateway_resource" "members" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.group_id.id
  path_part   = "members"
}

resource "aws_api_gateway_resource" "sessions" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_rest_api.psydoc.root_resource_id
  path_part   = "sessions"
}

resource "aws_api_gateway_resource" "session_id" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.sessions.id
  path_part   = "{sessionId}"
}

resource "aws_api_gateway_resource" "sign" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.session_id.id
  path_part   = "sign"
}

resource "aws_api_gateway_resource" "documents" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_rest_api.psydoc.root_resource_id
  path_part   = "documents"
}

resource "aws_api_gateway_resource" "document_id" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.documents.id
  path_part   = "{documentId}"
}

resource "aws_api_gateway_resource" "export" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id
  parent_id   = aws_api_gateway_resource.documents.id
  path_part   = "export"
}

resource "aws_api_gateway_method" "clients_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.clients.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "clients_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.clients.id
  http_method             = aws_api_gateway_method.clients_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["clients-create"]}/invocations"
}

resource "aws_api_gateway_method" "clients_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.clients.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "clients_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.clients.id
  http_method             = aws_api_gateway_method.clients_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["clients-list"]}/invocations"
}

resource "aws_api_gateway_method" "client_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.client_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "client_id_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.client_id.id
  http_method             = aws_api_gateway_method.client_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["clients-get"]}/invocations"
}

resource "aws_api_gateway_method" "consents_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.consents.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "consents_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.consents.id
  http_method             = aws_api_gateway_method.consents_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["consents-create"]}/invocations"
}

resource "aws_api_gateway_method" "consents_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.consents.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "consents_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.consents.id
  http_method             = aws_api_gateway_method.consents_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["consents-get"]}/invocations"
}

resource "aws_api_gateway_method" "groups_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.groups.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "groups_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.groups.id
  http_method             = aws_api_gateway_method.groups_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["groups-create"]}/invocations"
}

resource "aws_api_gateway_method" "group_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.group_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "group_id_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.group_id.id
  http_method             = aws_api_gateway_method.group_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["groups-get"]}/invocations"
}

resource "aws_api_gateway_method" "members_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.members.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "members_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.members.id
  http_method             = aws_api_gateway_method.members_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["groups-add-member"]}/invocations"
}

resource "aws_api_gateway_method" "sessions_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.sessions.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "sessions_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.sessions.id
  http_method             = aws_api_gateway_method.sessions_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["sessions-create"]}/invocations"
}

resource "aws_api_gateway_method" "sessions_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.sessions.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "sessions_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.sessions.id
  http_method             = aws_api_gateway_method.sessions_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["sessions-list"]}/invocations"
}

resource "aws_api_gateway_method" "sessions_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.session_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "sessions_id_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.session_id.id
  http_method             = aws_api_gateway_method.sessions_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["sessions-get"]}/invocations"
}

resource "aws_api_gateway_method" "sessions_sign_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.sign.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "sessions_sign_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.sign.id
  http_method             = aws_api_gateway_method.sessions_sign_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["sessions-sign"]}/invocations"
}

resource "aws_api_gateway_method" "document_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.document_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "document_id_get" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.document_id.id
  http_method             = aws_api_gateway_method.document_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["documents-get"]}/invocations"
}

resource "aws_api_gateway_method" "document_export_post" {
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  resource_id   = aws_api_gateway_resource.export.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "document_export_post" {
  rest_api_id             = aws_api_gateway_rest_api.psydoc.id
  resource_id             = aws_api_gateway_resource.export.id
  http_method             = aws_api_gateway_method.document_export_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${local.lambda_uri}/${var.function_arns["documents-export"]}/invocations"
}

resource "aws_api_gateway_deployment" "psydoc" {
  rest_api_id = aws_api_gateway_rest_api.psydoc.id


  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.clients_post.id,
      aws_api_gateway_integration.clients_get.id,
      aws_api_gateway_integration.client_id_get.id,
      aws_api_gateway_integration.consents_post.id,
      aws_api_gateway_integration.consents_get.id,
      aws_api_gateway_integration.groups_post.id,
      aws_api_gateway_integration.group_id_get.id,
      aws_api_gateway_integration.members_post.id,
      aws_api_gateway_integration.sessions_post.id,
      aws_api_gateway_integration.sessions_get.id,
      aws_api_gateway_integration.sessions_id_get.id,
      aws_api_gateway_integration.sessions_sign_post.id,
      aws_api_gateway_integration.document_id_get.id,
      aws_api_gateway_integration.document_export_post.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.clients_post,
    aws_api_gateway_integration.clients_get,
    aws_api_gateway_integration.client_id_get,
    aws_api_gateway_integration.consents_post,
    aws_api_gateway_integration.consents_get,
    aws_api_gateway_integration.groups_post,
    aws_api_gateway_integration.group_id_get,
    aws_api_gateway_integration.members_post,
    aws_api_gateway_integration.sessions_post,
    aws_api_gateway_integration.sessions_get,
    aws_api_gateway_integration.sessions_id_get,
    aws_api_gateway_integration.sessions_sign_post,
    aws_api_gateway_integration.document_id_get,
    aws_api_gateway_integration.document_export_post,
  ]
}

resource "aws_api_gateway_stage" "psydoc" {
  deployment_id = aws_api_gateway_deployment.psydoc.id
  rest_api_id   = aws_api_gateway_rest_api.psydoc.id
  stage_name    = var.environment
}