################################################
# 1. SG 생성
# 2. EC2 생성
################################################

# 1. SG 생성
# ingress: 80/tcp, 443/tcp
# egress: all traffic

resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS inbound 80/tcp, 443/tcp traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "mySG_22" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "mySG_80" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "mySG_443" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "mySG_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

###################################
#2 EC2 생성
# user_data(80/tcp, 443/tcp)
# => user_data 변경 시 ec2 인스턴스 재생성 필요
# security_group(mySG) 포함
# 새로 생성된 mySubSN에 인스턴스 위치 | *subnet_id 들어가야 함*


#keypair 생성
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}


resource "aws_instance" "myEC2" {
  ami                         = "ami-00e428798e77d38d9"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.mySG.id]
  subnet_id                   = aws_subnet.myPubSN.id
  key_name                    = "mykeypair"
  user_data                   = <<-EOF
            #!/bin/bash
            dnf install -y httpd mod_ssl
            echo "<h1>Welcome to Terraform Lab</h1>" > /var/www/html/index.html
            systemctl enable --now httpd
            EOF
  user_data_replace_on_change = true
  tags = {
    Name = "myEC2"
  }
}
