provider "aws" {
    region = var.aws_region
}

module "myvpc" {
    source = "../modules/vpc"

}

module "my_ec2"{
    source = "../modules/ec2"
    subnet_id = module.myvpc_subnet.id
}

