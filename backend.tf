terraform {
  required_version = ">= 0.12.31"
  required_providers {
    aws = ">=3.0.0"
  }

  backend "s3" {
    region  = "eu-central-1"
    profile = "default"
    key     = "terraform-state-file/statefile.tfstate"
    bucket  = "terraform-state-cname-bucket-9"
  }
}