terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    region  = "eu-central-1"
    profile = "default"
    key     = "terraform-state-file/statefile.tfstate"
    bucket  = "terraform-state-cname-bucket-4"
  }
}