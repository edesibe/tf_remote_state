resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
            "Condition": {
                "StringNotEqualsIfExists": {
                    "s3:x-amz-server-side-encryption": "SSE-KMS",
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": "${aws_kms_key.this.arn}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_object.this]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.prefix}-remote-state-${var.region}-${var.environment}"

  // change this to true to remove non-empty s3 bucket
  force_destroy = var.force_removal

  // We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.prefix}-remote-state-${var.region}-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "this" {
  bucket     = aws_s3_bucket.this.id
  key        = "tfstate-aws/"
  kms_key_id = aws_kms_key.this.arn
  depends_on = [aws_s3_bucket.this]
}
