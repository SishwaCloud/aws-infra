
variable "region" {
  description = "The AWS region in which to create the VPC and subnets"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "profile" {
  description = "The AWS profile to use"
  default     = "demo"
}
variable "ami_id" {
  type        = string
  description = "The AMI to use for the instance"
}

variable "VpcName" {
  description = "The AWS VPC Name to use"

}
