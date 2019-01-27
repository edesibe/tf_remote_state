# AWS remote_state module for Terraform
A lightweight remote_state module for Terraform.

## Usage
```
module "remote_state" {
  source = "github.com/edesibe/tf_vpc"
  region = "eu-central-1"
  prefix = "examplecom"
  environment = "developer"
}
```
See `interface.tf` for additional configurable variables.

## License
MIT
