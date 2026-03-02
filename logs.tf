# =============================================================================
# logs.tf - CloudWatch Log Group, Metric Filter & Custom Metric
# =============================================================================

# ─── Log Group ────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  # Encrypt log data at rest with AWS-managed key
  # For stricter compliance, replace with a customer-managed KMS key
  kms_key_id = null # set to your KMS key ARN for BYOK

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-logs"
    Purpose = "EC2 application log storage"
  })
}

# ─── Metric Filter ────────────────────────────────────────────────────────────
# Scans each log event for the literal string "ERROR" and increments a
# custom CloudWatch metric each time it appears.

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${local.name_prefix}-error-filter"
  log_group_name = aws_cloudwatch_log_group.app_logs.name

  # Simple string match — adjust to a JSON filter pattern for structured logs
  # e.g.  { $.level = "ERROR" }
  pattern = "ERROR"

  metric_transformation {
    name          = "ApplicationErrorCount"
    namespace     = "Custom/Application"
    value         = "1"          # Increment by 1 for each matching log event
    default_value = "0"          # Emit 0 when no errors occur (avoids alarm gaps)
    unit          = "Count"
  }
}

# ─── Additional Metric Filter: CRITICAL ──────────────────────────────────────
# Optional second filter to separately track CRITICAL severity events

resource "aws_cloudwatch_log_metric_filter" "critical_filter" {
  name           = "${local.name_prefix}-critical-filter"
  log_group_name = aws_cloudwatch_log_group.app_logs.name

  pattern = "CRITICAL"

  metric_transformation {
    name          = "ApplicationCriticalCount"
    namespace     = "Custom/Application"
    value         = "1"
    default_value = "0"
    unit          = "Count"
  }
}
