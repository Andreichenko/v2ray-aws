provider "aws" {
  profile = var.profile
  region  = var.region-common
  alias   = "region-common"
  //need to create modules for each resources for ec2 and vpc
}
