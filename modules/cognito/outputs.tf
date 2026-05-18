output "user_pool_id" {
  value = aws_cognito_user_pool.psydoc.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.frontend.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.psydoc.arn
}