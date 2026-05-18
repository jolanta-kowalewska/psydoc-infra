output "rest_api_id" {
  description = "The REST API identifier"
  value       = aws_api_gateway_rest_api.psydoc.id
}

output "base_url" {
  description = "Base URL API Gateway"
  value       = aws_api_gateway_stage.psydoc.invoke_url
}