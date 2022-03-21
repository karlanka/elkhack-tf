# set up bucket
resource "aws_s3_bucket" "stage_bucket" {
  bucket        = local.stage_bucket_name
  force_destroy = true
}

# set up topic where bucket will post create events
resource "aws_sns_topic" "elkhack_topic" {
  name = local.bucket_notification_topic_name
}

# add create event notifications from bucket to topic
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.stage_bucket.id

  topic {
    topic_arn     = aws_sns_topic.elkhack_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".json"
  }
}

# import policy document for allowing snowflake sqs to subscribe to topic
data "snowflake_system_get_aws_sns_iam_policy" "this" {
  aws_sns_topic_arn = aws_sns_topic.elkhack_topic.arn
}

# policy document for allowing bucket to post to topic
data "aws_iam_policy_document" "sns_bucket_post_topic_policy" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.elkhack_topic.arn]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"

      values = [aws_s3_bucket.stage_bucket.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

# merge the two policy documents..
data "aws_iam_policy_document" "sns_topic_policy" {
  source_policy_documents = [
    data.snowflake_system_get_aws_sns_iam_policy.this.aws_sns_topic_policy_json,
    data.aws_iam_policy_document.sns_bucket_post_topic_policy.json
  ]
}

# .. and attach to topic
resource "aws_sns_topic_policy" "publish_topic_policy" {
  arn    = aws_sns_topic.elkhack_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}