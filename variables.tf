variable "region" {
  default     = "eu-central-1"
  description = "The AWS region"
  type        = string
}

variable "prefix" {
  default     = "examplecom"
  description = "The name of our org, i.e. examplecom"
  type        = string
}

variable "environment" {
  default     = "development"
  description = "The name of our environment, i.e. development"
  type        = string
}

variable "force_destroy" {
  default     = false
  description = "Set true if you wanna destroy s3 bucket and its objects"
  type        = bool
}

