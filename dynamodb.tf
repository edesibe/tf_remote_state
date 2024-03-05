resource "aws_dynamodb_table" "this" {
  name           = "${var.prefix}-state-lock-${var.region}-${var.environment}"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  // We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
  //lifecycle {
  //  prevent_destroy = true
  //}


  tags = {
    Name = "${var.prefix}-state-lock-${var.region}-${var.environment}"
    Env  = var.environment
  }
}
