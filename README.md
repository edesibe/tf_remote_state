# AWS remote_state module for Terraform
A lightweight remote_state module for Terraform.

## Usage
```
module "remote_state" {
  source        = "git@github.com:edesibe/tf_remote_state"
  region        = "eu-central-1"
  prefix        = "edesibecom"
  environment   = "dev"
  force_removal = "false"
}
```
See `variables.tf` for additional configurable variables.

## License
MIT
