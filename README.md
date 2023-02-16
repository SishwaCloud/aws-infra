# aws-infra

## Terraform Commands
1. To Initialize - terraform init
2. To check what are created - terraform plan
3. To execute and create in aws - terraform apply
4. To delete all the created files - terraform destroy
5. To set the Variable Fields - terraform apply -var "variablename=variablevalue"

## Requirements
1. Created a new private GitHub repository with name "aws-infra" in the GitHub organization.
2. Created Virtual Private Cloud (VPC), 3 public subnets and 3 private subnets
3. Created an Internet Gateway attach the Internet Gateway to the VPC.
4. Created a public route table and attach all public subnets created to the route table.
5. Create a private route table and attach all private subnets created to the route table.
6. Created a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.