# get our aws account details
data "aws_caller_identity" "current" {}

# create variables used in storage integration, stage, and pipe
locals {
  current_account_id = data.aws_caller_identity.current.account_id
  snowflake_role_arn = "arn:aws:iam::${local.current_account_id}:role/${local.snowflake_role_name}"
  table_name_fq      = "${snowflake_database.elkhack_demo_db.name}.${snowflake_schema.elkhack_demo_schema.name}.${snowflake_table.elkhack_demo_table.name}"
  stage_name_fq      = "${snowflake_database.elkhack_demo_db.name}.${snowflake_schema.elkhack_demo_schema.name}.${snowflake_stage.elkhack_stage.name}"
}

# storage integration, allowing snowflake aws account to communicate with our aws account
resource "snowflake_storage_integration" "elkhack_integration" {
  name                      = local.storage_integration_name
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.stage_bucket.id}"]
  storage_aws_role_arn      = local.snowflake_role_arn
}

# external stage pointing to our s3 bucket
resource "snowflake_stage" "elkhack_stage" {
  name                = local.external_stage_name
  database            = snowflake_database.elkhack_demo_db.name
  schema              = snowflake_schema.elkhack_demo_schema.name
  storage_integration = snowflake_storage_integration.elkhack_integration.name
  url                 = "s3://${aws_s3_bucket.stage_bucket.id}"
}

# snowpipe loading from our bucket
resource "snowflake_pipe" "elkhack_pipe" {
  database          = snowflake_database.elkhack_demo_db.name
  schema            = snowflake_schema.elkhack_demo_schema.name
  name              = local.snowpipe_name
  aws_sns_topic_arn = aws_sns_topic.elkhack_topic.arn

  copy_statement = "copy into ${local.table_name_fq} from @${local.stage_name_fq} file_format = (type = json)"
  auto_ingest    = true
}