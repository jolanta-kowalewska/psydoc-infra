resource "aws_kms_key" "psydoc" {
  description             = "${var.project}-${var.environment} KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "psydoc" {
  name          = "alias/${var.project}-${var.environment}"
  target_key_id = aws_kms_key.psydoc.key_id
}