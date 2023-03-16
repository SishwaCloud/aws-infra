
variable "region" {
  description = "The AWS region in which to create the VPC and subnets"

}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"

}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"

}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"

}

variable "profile" {
  description = "The AWS profile to use"

}
variable "ami_id" {
  type        = string
  description = "The AMI to use for the instance"
}

variable "VpcName" {
  description = "The AWS VPC Name to use"
}

variable "db_port" {
  type        = number
  description = "The port to use for the database"

}

variable "dbusername" {
  type        = string
  description = "The username for the database"

}

variable "dbpassword" {
  type        = string
  description = "The password for the database"

}

variable "dbname" {
  type        = string
  description = "The name for the database"

}

variable "server_port" {
  type        = number
  description = "The port for the server"

}

variable "domain_name" {
  type        = string
  description = "domain name"
}

variable "zone_id" {
  type        = string
  description = "Zone ID"

}
