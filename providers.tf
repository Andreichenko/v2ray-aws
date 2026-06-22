provider "aws" {
  profile = var.profile
  region  = var.region-common
  alias   = "region-common"
}

provider "azurerm" {
  features {}
}
// need to add modules after redeploy