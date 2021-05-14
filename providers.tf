provider "aws" {
  profile = var.profile
  region  = var.region-common
  alias   = "region-common"
}
