variable "profile" {
  type        = string
  default     = "default"
  description = "The common profile for aws"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The common type of instance"
}

variable "region-common" {
  type        = string
  default     = "eu-central-1"
  description = "The common region"
}

variable "vpc_name" {
  description = "The Name of the common VPC"
  type        = string
  default     = "v2ray common VPC"
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block of the common VPC"
  type        = string
  default     = "10.0.0.0/16"
}

