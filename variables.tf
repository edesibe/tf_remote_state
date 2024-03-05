variable "environment" {
  default     = "development"
  description = "The name of our environment, i.e. development"
  type        = string
}

variable "region" {
  default     = "ca-central-1"
  description = "The AWS region"
  type        = string
}

variable "prefix" {
  default     = "edesibe"
  description = "The name of our org, i.e. edesibe.com"
  type        = string
}

variable "force_removal" {
  default     = "false"
  description = "Forcing removal of a non-empty S3 bucket"
  type        = string
}

variable "additional_roles" {
  default     = []
  description = "Additional roles that should be granted access to the tfstate"
  type        = list(any)
}

variable "role" {
  type        = string
  description = "AWS IAM role which will be allowd in s3 bucket policy"
}
