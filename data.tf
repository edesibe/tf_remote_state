data "aws_caller_identity" "current" {}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_iam_role" "additional_roles" {
  for_each = toset(var.additional_roles)
  name = each.key
}

# lookup the role arn
data "aws_iam_role" "role" {
  name = var.role
}
