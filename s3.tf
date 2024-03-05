resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.state_force_ssl.json
  depends_on = [aws_s3_bucket_public_access_block.this]
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
  bucket     = aws_s3_bucket.this.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.prefix}-remote-state-${var.region}-${var.environment}"

  // change this to true to remove non-empty s3 bucket
  force_destroy = var.force_removal

  tags = {
    Name = "${var.prefix}-remote-state-${var.region}-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "this" {
  bucket     = aws_s3_bucket.this.id
  key        = "tfstate-aws/"
  kms_key_id = data.aws_kms_alias.s3.arn
  depends_on = [aws_s3_bucket.this]
}
