variable "region" {
  default     = "eu-central-1"
  description = "The AWS region"
}

variable "prefix" {
  default     = "mttnowcom"
  description = "The name of our org, i.e. mttnowcom"
}

variable "environment" {
  default     = "development"
  description = "The name of our environment, i.e. development"
}
