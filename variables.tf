variable "profile" {
  type        = string
  default     = "default"
  description = "The main profile for aws credentials"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The main type of instance in this case"
}

variable "region-common" {
  type        = string
  default     = "eu-central-1"
  description = "The main region"
}

variable "vpc_should_be_created" {
  description = "Should the VPC be created?"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The Name of the VPC"
  type        = string
  default     = "v2ray VPC"
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  description = "Should instances in the VPC get public DNS hostnames?"
  type        = bool
  default     = false
}

variable "vpc_enable_dns_support" {
  description = "Should the DNS resolution be supported?"
  type        = bool
  default     = false
}
