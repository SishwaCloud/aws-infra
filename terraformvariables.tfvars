
region                     = "us-east-1"
vpc_cidr_block             = "10.0.0.0/16"
public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
dbusername                 = "csye6225"
dbpassword                 = "Sishwareddy11"
dbname                     = "csye6225"
db_port                    = "3306"
server_port                = "3000"
ami_id                     = "ami-0bf54c1722e585075"

#dev
# profile     = "dev"
# domain_name = "dev.sishwa.me"
# zone_id     = "Z09656563M32KNJFPC4J0"

#demo
profile     = "demo"
domain_name = "demo.sishwa.me"
zone_id     = "Z0962879IBJMMB6EMHFB"
