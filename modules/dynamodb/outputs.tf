output "table_arn" {
  value = aws_dynamodb_table.psydoc.arn
}

output "table_name" {
  value = aws_dynamodb_table.psydoc.name
}