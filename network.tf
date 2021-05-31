# Creating VPC for eu-central-1
resource "aws_vpc" "vpc-central-1" {
  provider             = aws.region-common
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "common-vpc-v2ray"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
    Region      = "eu-central-1"
  }
}

#Get all available AZ's in VPC for common
data "aws_availability_zones" "azs" {
  provider = aws.region-common
  state    = "available"
}


#Create subnet for common VPC
resource "aws_subnet" "subnet-1a" {
  provider                = aws.region-common
  cidr_block              = "10.0.0.0/20"
  vpc_id                  = aws_vpc.vpc-central-1.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
  tags = {
    Name        = "Common subnet primary"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
    Region      = "eu-central-1"
    Zone        = "zone-1a"
  }
}

resource "aws_subnet" "subnet-1b" {
  provider                = aws.region-common
  cidr_block              = "10.0.16.0/20"
  vpc_id                  = aws_vpc.vpc-central-1.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
  tags = {
    Name        = "Common subnet primary"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
    Region      = "eu-central-1"
    Zone        = "zone-1b"
  }
}
// need to create a module
resource "aws_subnet" "subnet-1c" {
  provider                = aws.region-common
  cidr_block              = "10.0.32.0/20"
  vpc_id                  = aws_vpc.vpc-central-1.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
  tags = {
    Name        = "Common subnet primary"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
    Region      = "eu-central-1"
    Zone        = "zone-1c"
  }
}

resource "aws_internet_gateway" "internet-gateway-vpc-central-1" {
  provider = aws.region-common
  vpc_id   = aws_vpc.vpc-central-1.id
  tags = {
    Name        = "Common IGW"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
    Region      = "eu-central-1"
  }
}

resource "aws_route_table" "public-routes" {
  provider = aws.region-common
  vpc_id   = aws_vpc.vpc-central-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-vpc-central-1.id
  }

  tags = {
    Name = "Common-Route-table"
  }
}

#Owerwrite default route table of VPC common with our route table entries
resource "aws_main_route_table_association" "set-common-worker-rt-associate" {
  route_table_id = aws_route_table.public-routes.id
  vpc_id         = aws_vpc.vpc-central-1.id
  provider       = aws.region-common
}
