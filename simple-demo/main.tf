# define provider and its version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
}

# set up provider for accessing AWS resources
# uses aws access keys in ~/.aws
provider "aws" {
  region  = "eu-west-1"
  profile = "antondev"
}


resource "aws_s3_bucket" "demo_bucket" {
  bucket = "elkhack-simple-demo-bucket"
}

# # set up external state storage
# terraform {
#   backend "s3" {
#     encrypt        = "true"
#     bucket         = "anton-terraform-state"
#     dynamodb_table = "anton-terraform-lock"
#     key            = "anton-elkhacking-simple-demo.tfstate"
#     region         = "eu-west-1"
#     profile        = "antondev"
#   }
# }