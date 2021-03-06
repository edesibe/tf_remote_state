resource "aws_kms_key" "state_key" {
  description = "Infrastructure State Encryption"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY


  // We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.prefix}-state-lock-${var.region}-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_kms_alias" "state_key_alias" {
  name          = "alias/${var.prefix}-${var.region}-${var.environment}-key"
  target_key_id = aws_kms_key.state_key.key_id
}
