########################
# 1. NAT Gateway 생성 -> Public Subnet
# 2. Private Subnet 생성
# 3. Private Routing Table 생성 및 연결
# 4. SG 그룹 생성
# 5. EC2 생성 (Private Subnet)
########################

# 1. NAT Gateway 생성 -> Public Subnet
# EIP 생성 / https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "myEIP" {
  domain = "vpc"
  tags = {
    Name = "myEIP"
  }
}
# NAT Gateway를 public subnet에 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway

resource "aws_nat_gateway" "myNAT-gw" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.myPubSN.id

  tags = {
    Name = "myNAT-gw"
  }

  depends_on = [aws_internet_gateway.myIGW]
}


# 2. Private Subnet 생성
resource "aws_subnet" "myPriSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "myPriSN"
  }
}

# 3. Private Routing Table 생성 및 연결
# Private Route Table 생성
# NAT Gateway를 default route로 추가, Private Subnet과 연결

resource "aws_route_table" "mypriRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT-gw.id
  }

  tags = {
    Name = "mypriRT"
  }
}

resource "aws_route_table_association" "myPriRTassoc" {
  subnet_id      = aws_subnet.myPriSN.id
  route_table_id = aws_route_table.mypriRT.id
}

# 4. SG 그룹 생성
# myEC2-2가 사용할 SG 그룹 생성
# 22/tcp, 80/tcp, 443/tcp

resource "aws_security_group" "mySG2" {
  name        = "mySG2"
  description = "Allow TLS inbound 22/tcp, 80/tcp, 443/tcp traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_22" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_80" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_443" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "mySG2_all" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 5. EC2 생성 (Private Subnet)
# user_data(Web server, SSH 접속 허용)
# user_data 변경 시 ec2 인스턴스 재생성 필요
# security_group(mySG2) 포함
# 키페어 생성 및 설정 - myKeyPair



resource "aws_instance" "myEC2-2" {
  ami           = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"



  vpc_security_group_ids = [aws_security_group.mySG2.id]
  subnet_id              = aws_subnet.myPriSN.id
  key_name               = "mykeypair"

  user_data                   = <<-EOF
            #!/bin/bash
            dnf install -y httpd mod_ssl
            echo "<h1>My Web Server2</h1>" > /var/www/html/index.html
            systemctl enable --now httpd
            EOF
  user_data_replace_on_change = true
  tags = {
    Name = "myEC2-2"
  }

}