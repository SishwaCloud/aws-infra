
provider "aws" {
  region  = var.region
  profile = var.profile
}


# data "aws_ami" "latest" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["csye6225_*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["amazon"]

# }



resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.VpcName
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.VpcName}-my-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(data.aws_availability_zones.available.names) > 2 ? 3 : 2
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.VpcName}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(data.aws_availability_zones.available.names) > 2 ? 3 : 2
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = " ${var.VpcName}-private-subnet-${count.index + 1} "
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.VpcName}public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.VpcName}-private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}




# resource "aws_security_group" "app_security_group" {
#   name_prefix = "app_security_group"

#   vpc_id = aws_vpc.my_vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Add ingress rule for the port your application runs on
#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Launch the EC2 instance
# resource "aws_instance" "example_instance" {
#   ami                         = data.aws_ami.latest.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public_subnets[0].id
#   vpc_security_group_ids      = [aws_security_group.webapp_security_group.id]
#   associate_public_ip_address = true
#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = 50
#     delete_on_termination = true
#   }

#   iam_instance_profile = aws_iam_instance_profile.profile.name
#   user_data            = <<EOF
# 		#! /bin/bash
#   echo DB_HOST=${aws_db_instance.db_instance.address} >> /etc/environment
#   echo DB_USER=${aws_db_instance.db_instance.username} >> /etc/environment
#   echo DB_PASSWORD=${aws_db_instance.db_instance.password} >> /etc/environment
#   echo DB_NAME=${aws_db_instance.db_instance.db_name} >> /etc/environment
#   echo NODE_PORT=${var.server_port} >> /etc/environment
#   echo DB_PORT=${var.db_port} >> /etc/environment
#   echo S3_BUCKET_NAME=${aws_s3_bucket.private_bucket.bucket} >> /etc/environment
#   sudo systemctl daemon-reload
#   sudo systemctl restart nodeapp
# 	EOF


#   # Disable termination protection
#   disable_api_termination = false
# }

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable mysql/aurora access on port 3306"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "mysql/aurora access"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_security_group.id]
  }

  tags = {
    Name = "database security group"
  }
}

resource "aws_db_subnet_group" "private_subnet" {
  subnet_ids = aws_subnet.private_subnets[*].id
  name       = "database"
}

# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                 = "mysql"
  engine_version         = "8.0.31"
  multi_az               = "false"
  identifier             = "csye6225"
  username               = var.dbusername
  password               = var.dbpassword //var.db_password
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.private_subnet.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  parameter_group_name   = aws_db_parameter_group.db.name
  db_name                = var.dbname
  skip_final_snapshot    = "true"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "private-bucket-${var.environment}-${random_id.random_bucket_suffix.hex}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "examplebucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "random_id" "random_bucket_suffix" {
  byte_length = 4
}

variable "environment" {}

resource "aws_iam_policy" "webapp_s3_policy" {
  name        = "WebAppS3"
  description = "Allows EC2 instances to perform S3 actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_db_parameter_group" "db" {
  name_prefix = "db-"
  family      = "mysql8.0"
  description = "Parameter group for MySQL 8.0"
}
resource "aws_iam_role" "ec2_csye6225_role" {
  name = "EC2-CSYE6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "webapp_s3_policy_attachment" {
  policy_arn = aws_iam_policy.webapp_s3_policy.arn
  role       = aws_iam_role.ec2_csye6225_role.name
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.ec2_csye6225_role.name
}



resource "aws_route53_record" "example_record" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.webapp_lb.dns_name
    zone_id                = aws_lb.webapp_lb.zone_id
    evaluate_target_health = true
  }
}


data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "EC2-CW" {
  role       = aws_iam_role.ec2_csye6225_role.name
  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

resource "aws_cloudwatch_log_group" "csye" {
  name = "csye6225"
}

resource "aws_cloudwatch_log_stream" "webapp" {
  name           = "webapp"
  log_group_name = aws_cloudwatch_log_group.csye.name
}



data "aws_availability_zones" "available" {}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.my_igw.id
}

# output "latest_ami" {
#   value = data.aws_ami.latest.id
# }








resource "aws_security_group" "webapp_security_group" {
  name_prefix = "webapp_security_group"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "load_balancer_security_group" {
  name        = "load_balancer_security_group"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "load_balancer_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

resource "aws_lb_target_group" "target_group" {
  name     = "webapp-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    enabled             = "true"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/healthz"
    matcher             = "200"
    port                = var.server_port
  }
}

resource "aws_lb" "webapp_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"

  subnets         = aws_subnet.public_subnets.*.id
  security_groups = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name = "webapp-lb"
  }
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}


locals {
  user_data_ec2 = <<EOF
		#! /bin/bash
  echo DB_HOST=${aws_db_instance.db_instance.address} >> /etc/environment
  echo DB_USER=${aws_db_instance.db_instance.username} >> /etc/environment
  echo DB_PASSWORD=${aws_db_instance.db_instance.password} >> /etc/environment
  echo DB_NAME=${aws_db_instance.db_instance.db_name} >> /etc/environment
  echo NODE_PORT=${var.server_port} >> /etc/environment
  echo DB_PORT=${var.db_port} >> /etc/environment
  echo S3_BUCKET_NAME=${aws_s3_bucket.private_bucket.bucket} >> /etc/environment
  sudo systemctl daemon-reload
  sudo systemctl restart nodeapp
	EOF
}

# Create a launch template
resource "aws_launch_template" "webapp_launch_template" {
  name          = "webapp-launch-template"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = "ssh"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webapp_security_group.id]
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }
  user_data = base64encode(local.user_data_ec2)

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-app-instance"
    }
  }
}


resource "aws_autoscaling_group" "webapp-autoscaling-group" {
  name                = "webapp-autoscaling-group"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  default_cooldown    = 60
  vpc_zone_identifier = aws_subnet.public_subnets.*.id
  target_group_arns   = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = aws_launch_template.webapp_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
  tag {
    key                 = "AutoScalingGroup"
    value               = "true"
    propagate_at_launch = true
  }
}


# AutoScaling Policies
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale_up_policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp-autoscaling-group.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale_down_policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp-autoscaling-group.name
}


# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_scale_up" {
  alarm_name          = "cpu-utilization-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "This metric monitors EC2 CPU utilization and scales up when the threshold is exceeded"
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-autoscaling-group.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_scale_down" {
  alarm_name          = "cpu-utilization-scale-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"
  alarm_description   = "This metric monitors EC2 CPU utilization and scales down when the threshold is below"
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-autoscaling-group.name
  }
}


# Application Load Balancer

# Target Group Attachment
resource "aws_autoscaling_attachment" "webapp-autoscaling-group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp-autoscaling-group.name
  alb_target_group_arn   = aws_lb_target_group.target_group.arn
}








output "load_balancer_dns_name" {
  value = aws_lb.webapp_lb.dns_name
}
