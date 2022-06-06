terraform {
  # uncomment to enable `optional()` function in variables
  # experiments = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
