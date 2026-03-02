# =============================================================================
# alarms.tf - CloudWatch Alarms with SNS Notifications
# =============================================================================

# ─── CPU Utilization Alarm ────────────────────────────────────────────────────
# Triggers when EC2 CPU goes above the threshold for N consecutive periods

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-utilization-high"
  alarm_description   = "EC2 CPU utilization exceeded ${var.cpu_alarm_threshold}% for ${var.alarm_evaluation_periods} consecutive ${var.alarm_period_seconds}s periods"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  treat_missing_data  = "notBreaching" # missing data = OK (instance might be stopped)

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  # Send both ALARM and OK state changes to SNS
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-cpu-utilization-high"
    Severity = "High"
  })
}

# ─── Application Error Alarm ──────────────────────────────────────────────────
# Fires when the custom "ApplicationErrorCount" metric exceeds the threshold.
# This metric is produced by the log metric filter in logs.tf.

resource "aws_cloudwatch_metric_alarm" "app_errors_high" {
  alarm_name          = "${local.name_prefix}-application-errors-high"
  alarm_description   = "Application error count exceeded ${var.error_alarm_threshold} in the last ${var.alarm_period_seconds}s"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ApplicationErrorCount"
  namespace           = "Custom/Application"
  period              = var.alarm_period_seconds
  statistic           = "Sum" # Sum is correct for counting events
  threshold           = var.error_alarm_threshold
  treat_missing_data  = "notBreaching"

  # No dimensions — metric filter publishes without dimensions
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-application-errors-high"
    Severity = "Critical"
  })
}

# ─── Application CRITICAL Alarm ───────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "app_critical_high" {
  alarm_name          = "${local.name_prefix}-application-critical-high"
  alarm_description   = "Application CRITICAL log events detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1 # Fire immediately on first CRITICAL
  metric_name         = "ApplicationCriticalCount"
  namespace           = "Custom/Application"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = 0 # Any CRITICAL event is an alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-application-critical-high"
    Severity = "Critical"
  })
}

# ─── Network In Alarm (optional safety net) ──────────────────────────────────
# Useful for detecting unexpected data-ingress spikes (DDoS, data exfil, etc.)

resource "aws_cloudwatch_metric_alarm" "network_in_high" {
  alarm_name          = "${local.name_prefix}-network-in-high"
  alarm_description   = "EC2 NetworkIn exceeded 1 GB in the last 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 1073741824 # 1 GB in bytes
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-network-in-high"
    Severity = "Medium"
  })
}
