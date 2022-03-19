# role assumed by snowflake aws account when loading data
# create in our aws account
resource "aws_iam_role" "stage_role" {
  name               = local.snowflake_role_name
  description        = "to be assumed by snowflake to load data"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

# policy document saying snowflake aws account is allowed to assume role
data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration.elkhack_integration.storage_aws_iam_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [snowflake_storage_integration.elkhack_integration.storage_aws_external_id]
    }
  }
}

# policy document defining actions above role can do
data "aws_iam_policy_document" "snowflake_stage_policy_document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["${aws_s3_bucket.stage_bucket.arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.stage_bucket.arn]
  }
}

# attach above policy to role
resource "aws_iam_role_policy" "snowflake_stage_policy" {
  name_prefix = "snowflake-stage-policy"
  role        = aws_iam_role.stage_role.id
  policy      = data.aws_iam_policy_document.snowflake_stage_policy_document.json
}



