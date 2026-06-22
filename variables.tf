variable "profile" {
  type        = string
  default     = "default"
  description = "The common profile for aws cli"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The common type of the instance"
}

variable "region-common" {
  type        = string
  default     = "eu-central-1"
  description = "The common region eu-central-1 for xray"
}

variable "vpc_name" {
  description = "The name of the common VPC in eu-central-1 xray vpc"
  type        = string
  default     = "The common VPC xray instance"
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block of the common VPC eu-central-1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "xray_port" {
  description = "The port Xray will listen on"
  type        = number
  default     = 443
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}
