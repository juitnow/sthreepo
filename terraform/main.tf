# ==============================================================================
# SETUP TERRAFORM
# ==============================================================================

# Fix versions
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    aws = ">= 4.13.0"
  }
}

# The default AWS provider in our Frankfurt region
provider "aws" {
  region = "eu-central-1"
}
