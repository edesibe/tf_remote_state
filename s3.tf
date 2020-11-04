resource "aws_s3_bucket_policy" "state-file-s3-policy" {
  bucket = aws_s3_bucket.state-file-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.state-file-bucket.id}/*",
            "Condition": {
                "StringNotEqualsIfExists": {
                    "s3:x-amz-server-side-encryption": "SSE-KMS",
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": "${aws_kms_key.state_key.arn}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "tfstate_bucket_blocker" {
  bucket = aws_s3_bucket.state-file-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket_object.tfstate_bucket_folder]
}

resource "aws_s3_bucket" "state-file-bucket" {
  bucket = "${var.prefix}-remote-state-${var.region}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  // change this to true to remove non-empty s3 bucket
  force_destroy = var.force_removal

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.state_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  // We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.prefix}-remote-state-${var.region}-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_s3_bucket_object" "tfstate_bucket_folder" {
  bucket     = aws_s3_bucket.state-file-bucket.id
  key        = "tfstate-aws/"
  kms_key_id = aws_kms_key.state_key.arn
  depends_on = [aws_s3_bucket.state-file-bucket]
}
