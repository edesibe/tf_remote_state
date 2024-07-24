# --------------------------
# CONFIGURE OUR AWS PROVIDER
# --------------------------

provider "aws" {
  region = var.region
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.59.0"
    }
  }
}

# ---------
# VARIABLES
# ---------

variable "environment" {
  default     = "stag"
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

# ---------
# RESOURCES
# ---------

module "remote_state" {
  source        = "../../"
  region        = var.region
  prefix        = var.prefix
  environment   = var.environment
  force_removal = var.force_removal
}

# ------
# OUTPUT
# ------

output "s3_bucket_id" { value = module.remote_state.s3_bucket_id }
output "aws_account_id" { value = module.remote_state.aws_account_id }
output "s3_policy" { value = module.remote_state.s3_policy }
