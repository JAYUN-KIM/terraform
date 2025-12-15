###############################
# 1. provider
###############################
provider "aws" {
  region = "us-east-2"
}

###############################
# 2. EC2
###############################

# default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "mysg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Amazon Linux 2023 AMI
data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

# Key Pair
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}

# EC2 Instance
resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name               = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "myInstance"
  }
}

# Output
output "ami_id" {
  description = "AMI ID"
  value       = aws_instance.myInstance.ami
}

output "myInstance_public_ip" {
  description = "Public IP of myInstance"
  value       = aws_instance.myInstance.public_ip
}

output "connect_SSH" {
  description = "Connect URI"
  value       = "ssh -i ~/.ssh/mykeypair.pem ec2-user@${aws_instance.myInstance.public_ip}"
}