variable "profile" {
  description = "The AWS profile to use"
  default     = "demo"

}

variable "region" {
  description = "The AWS region in which to create the VPC and subnets"
  default     = "us-east-1"
}

variable "VPCName" {
  description = "The name of the VPC"
}



variable "vpccidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block_1" {
  description = "The CIDR block for the first public subnet."
  default     = "10.0.1.0/24"

}

variable "public_subnet_cidr_block_2" {
  description = "The CIDR block for the second public subnet."
  default     = "10.0.2.0/24"

}
variable "public_subnet_cidr_block_3" {
  description = "The CIDR block for the third public subnet."
  default     = "10.0.3.0/24"
}


variable "private_subnet_cidr_block_1" {
  description = "The CIDR block for the first private subnet."
  default     = "10.0.4.0/24"
}

variable "private_subnet_cidr_block_2" {
  description = "The CIDR block for the second private subnet."
  default     = "10.0.5.0/24"
}

variable "private_subnet_cidr_block_3" {
  description = "The CIDR block for the third private subnet."
  default     = "10.0.6.0/24"
}


provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_vpc" "mainvpc" {
  cidr_block = var.vpccidr

  tags = {
    Name = var.VPCName
  }
}



resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.public_subnet_cidr_block_1
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name = "publicsubnet-1-${var.VPCName}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.public_subnet_cidr_block_2
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}b"
  tags = {
    Name = "publicsubnet-2-${var.VPCName}"
  }
}

resource "aws_subnet" "public_subnet_3" {
  cidr_block        = var.public_subnet_cidr_block_3
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}c"
  tags = {
    Name = "publicsubnet-3-${var.VPCName}"
  }
}


resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_cidr_block_1
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name = "privatesubnet-1-${var.VPCName}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_cidr_block_2
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}b"
  tags = {
    Name = "privatesubnet-2-${var.VPCName}"
  }
}

resource "aws_subnet" "private_subnet_3" {
  cidr_block        = var.private_subnet_cidr_block_3
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "${var.region}c"
  tags = {
    Name = "privatesubnet-3-${var.VPCName}"
  }
}


resource "aws_internet_gateway" "Internetgateway" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "InternetGateway-${var.VPCName}"
  }
}


resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internetgateway.id
  }

  tags = {
    Name = "publicroutetable-${var.VPCName}"
  }
}


resource "aws_route_table_association" "publicsubnet-1associations" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.publicroutetable.id
}


resource "aws_route_table_association" "publicsubnet-2associations" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.publicroutetable.id
}

resource "aws_route_table_association" "publicsubnet-3associations" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.publicroutetable.id
}


resource "aws_route_table" "privateroutetable" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "privateroutetable-${var.VPCName}"
  }
}


resource "aws_route_table_association" "privatesubnet-1associations" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.privateroutetable.id
}


resource "aws_route_table_association" "privatesubnet-2associations" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.privateroutetable.id
}

resource "aws_route_table_association" "privatesubnet-3associations" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.privateroutetable.id
}


