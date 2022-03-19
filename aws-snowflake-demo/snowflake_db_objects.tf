# create database
resource "snowflake_database" "elkhack_demo_db" {
  name = local.db_name
}

# create schema
resource "snowflake_schema" "elkhack_demo_schema" {
  database            = snowflake_database.elkhack_demo_db.name
  name                = local.schema_name
  data_retention_days = 1
}

# create table
resource "snowflake_table" "elkhack_demo_table" {
  database = snowflake_database.elkhack_demo_db.name
  schema   = snowflake_schema.elkhack_demo_schema.name
  name     = local.table_name

  column {
    name = "actual_data"
    type = "VARIANT"
  }
}