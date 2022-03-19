locals {
  # snowflake constants
  db_name                  = "ELKHACK_DEMO_DB"
  schema_name              = "ELKHACK_DEMO_SCHEMA"
  table_name               = "ELKHACK_DEMO_TABLE"
  storage_integration_name = "ELKHACK_STORAGE_INTEGRATION"
  external_stage_name      = "ELKHACK_STAGE"
  snowpipe_name            = "ELKHACK_DEMO_PIPE"

  # aws constants
  snowflake_role_name            = "snowflake_role"
  stage_bucket_name              = "elkhack-stage"
  bucket_notification_topic_name = "elkhack-topic"
}

# lock provider versions
terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.28.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
}

# set up external state storage
terraform {
  backend "s3" {
    encrypt        = "true"
    bucket         = "anton-terraform-state"
    dynamodb_table = "anton-terraform-lock"
    key            = "anton-elkhacking.tfstate"
    region         = "eu-west-1"
    profile        = "antondev"
  }
}

# set up provider for accessing AWS resources
# uses aws access keys in ~/.aws
provider "aws" {
  region  = "eu-west-1"
  profile = "antondev"
}

# set up provider for accessing Snowflake resource
# uses snowflake access keys in ~/.ssh
provider "snowflake" {
  role   = "ACCOUNTADMIN"
  region = "eu-west-1"
}