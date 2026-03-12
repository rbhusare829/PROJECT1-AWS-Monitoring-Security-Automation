# =============================================================================
# terraform.tfvars.example
# Copy this file to terraform.tfvars and fill in real values.
# NEVER commit terraform.tfvars with real account IDs or secrets to source control.
# =============================================================================

# ─── General ─────────────────────────────────────────────────────────────────
aws_region   = "ap-south-1"
project_name = "aws-monitoring"
environment  = "prod"
owner        = "devops-team"

# ─── Notifications ───────────────────────────────────────────────────────────
# Replace with the actual pager/on-call email for your team
alert_email    = "devops-alerts@example.com"
sns_topic_name = "cloudwatch-alerts"

# ─── EC2 ─────────────────────────────────────────────────────────────────────
# Replace with a real EC2 instance ID in your account
ec2_instance_id = "i-0123456789abcdef0"

# ─── CloudWatch Logs ─────────────────────────────────────────────────────────
log_group_name     = "/ec2/application/logs"
log_retention_days = 30

# ─── CloudWatch Alarms ───────────────────────────────────────────────────────
cpu_alarm_threshold      = 80
error_alarm_threshold    = 5
alarm_evaluation_periods = 2
alarm_period_seconds     = 300

# ─── CloudTrail / S3 ─────────────────────────────────────────────────────────
# Must be globally unique. Recommended: <orgname>-cloudtrail-logs-<account_id>
cloudtrail_s3_bucket_name = "myorg-cloudtrail-logs-123456789012"
enable_s3_access_logging  = true

# ─── Dashboard ───────────────────────────────────────────────────────────────
dashboard_name = "infrastructure-monitoring"
