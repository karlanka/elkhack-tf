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

# create bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "elkhack-simple-demo-bucket"
}

# policy to bucket allowing another account to read from it
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.demo_bucket.arn,
      "${aws_s3_bucket.demo_bucket.arn}/*",
    ]
  }
}

# attach policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}