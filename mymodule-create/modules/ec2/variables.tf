variable "vpc_id" {}
variable "subnet_id" {}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "free-key"
}
