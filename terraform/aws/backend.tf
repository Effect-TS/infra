terraform {
  backend "s3" {
    bucket         = "effectful-terraform-state"
    key            = "aws/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "effectful-terraform-state"
    encrypt        = true
  }
}
