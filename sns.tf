# =============================================================================
# sns.tf - SNS Topic & Email Subscription for CloudWatch Alarm Notifications
# =============================================================================

# ─── SNS Topic ────────────────────────────────────────────────────────────────

resource "aws_sns_topic" "alerts" {
  name         = "${local.name_prefix}-${var.sns_topic_name}"
  display_name = "CloudWatch Alerts - ${var.environment}"

  # Enforce server-side encryption using AWS-managed key
  kms_master_key_id = "alias/aws/sns"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-${var.sns_topic_name}"
    Purpose = "CloudWatch alarm notifications"
  })
}

# ─── SNS Topic Policy ─────────────────────────────────────────────────────────
# Allows CloudWatch to publish alarm state-change messages to this topic

resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:*"
          }
        }
      },
      {
        Sid    = "AllowAccountPublish"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# ─── Email Subscription ───────────────────────────────────────────────────────
# NOTE: AWS will send a confirmation email; the subscription stays "PendingConfirmation"
#       until the recipient clicks the link. This is expected Terraform behavior.

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
