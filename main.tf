resource "aws_s3_bucket" "remote_state" {
  bucket = "${var.prefix}-remote-state-${var.region}-${var.environment}"
  acl    = "private"
  region = var.region

  force_destroy = var.force_destroy

  versioning {
    enabled = true
  }


  tags = {
    Name = "${var.prefix}-remote-state-${var.region}-${var.environment}"
    ENV  = var.environment
  }
}

/*
resource "aws_dynamodb_table" "state-lock" {
  name           = "${var.prefix}-state-lock-${var.region}-${var.environment}"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.prefix}-state-lock-${var.region}-${var.environment}"
    ENV  = var.environment
  }
}
*/
