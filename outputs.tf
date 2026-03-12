# =============================================================================
# outputs.tf - Exported Values for Reference / Remote State Consumption
# =============================================================================

# ─── General ─────────────────────────────────────────────────────────────────

output "aws_account_id" {
  description = "AWS account ID where resources are deployed"
  value       = local.account_id
}

output "aws_region" {
  description = "Primary deployment region"
  value       = local.region
}

output "name_prefix" {
  description = "Resource name prefix used across all resources"
  value       = local.name_prefix
}

# ─── SNS ─────────────────────────────────────────────────────────────────────

output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.alerts.name
}

# ─── CloudWatch Logs ─────────────────────────────────────────────────────────

output "app_log_group_name" {
  description = "CloudWatch Log Group name for application logs"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "app_log_group_arn" {
  description = "ARN of the application CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.app_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "CloudWatch Log Group name for CloudTrail events"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

# ─── CloudWatch Alarms ───────────────────────────────────────────────────────

output "cpu_alarm_name" {
  description = "Name of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "app_error_alarm_name" {
  description = "Name of the application error count alarm"
  value       = aws_cloudwatch_metric_alarm.app_errors_high.alarm_name
}

output "app_error_alarm_arn" {
  description = "ARN of the application error alarm"
  value       = aws_cloudwatch_metric_alarm.app_errors_high.arn
}

# ─── CloudWatch Dashboard ────────────────────────────────────────────────────

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "dashboard_url" {
  description = "Direct URL to view the dashboard in the AWS Console"
  value       = "https://${local.region}.console.aws.amazon.com/cloudwatch/home?region=${local.region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# ─── Security ────────────────────────────────────────────────────────────────

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = aws_guardduty_detector.main.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_s3_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "config_s3_bucket_name" {
  description = "S3 bucket storing AWS Config snapshots"
  value       = aws_s3_bucket.config.id
}

output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.main.name
}
