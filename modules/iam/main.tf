resource "aws_iam_role" "lambda" {
  name = "${var.project}-${var.environment}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

#policy to write logs to CLoudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "${var.project}-${var.environment}-dynamodb-policy"
  role = aws_iam_role.lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = var.dynamo_table_arn
      },
    ]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.project}-${var.environment}-s3-policy"
  role = aws_iam_role.lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = "${var.s3_bucket_arn}/*" # obiekty wewnątrz bucketa
      },
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = var.s3_bucket_arn # sam bucket
      }
    ]
  })
}


resource "aws_iam_role_policy" "kms_policy" {
  name = "${var.project}-${var.environment}-kms-policy"
  role = aws_iam_role.lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"]
        Effect   = "Allow"
        Resource = var.kms_key_arn
      }
    ]
  })
}