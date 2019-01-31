variable "region" {
  default     = "eu-central-1"
  description = "The AWS region"
}

variable "prefix" {
  default     = "examplecom"
  description = "The name of our org, i.e. examplecom"
}

variable "environment" {
  default     = "development"
  description = "The name of our environment, i.e. development"
}

variable "force_destroy" {
  default = false
  description = "Set true if you wanna destroy s3 bucket and its objects"
}

