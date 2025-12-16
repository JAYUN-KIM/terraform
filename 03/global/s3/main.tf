##############################################
#1. S3 Bucket 생성
#2. dynanodb 생성
##############################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

resource "aws_s3_bucket" "my_tfstate" {
  bucket = "kjy-1111"

  tags = {
    Name        = "kjy-1111"
  }
}


#2. dynanodb 생성

resource "aws_dynamodb_table" "my_tflocks" {
  name           = "my_tflocks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "my_tflocks"
    
  }
}