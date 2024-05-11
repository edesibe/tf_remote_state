variable "environment" {
  description = "The name of our environment, i.e. development"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "prefix" {
  description = "The name of our org, i.e. edesibe.com"
  type        = string
}

variable "force_removal" {
  default     = "false"
  description = "Forcing removal of a non-empty S3 bucket"
  type        = string
}
