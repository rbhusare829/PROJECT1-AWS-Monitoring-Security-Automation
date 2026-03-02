# =============================================================================
# variables.tf - All Input Variables
# =============================================================================

# ─── General ─────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "Primary AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "aws-monitoring"
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Team or individual responsible for this infrastructure"
  type        = string
  default     = "devops-team"
}

# ─── SNS / Notifications ─────────────────────────────────────────────────────

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
  # No default - must be supplied in terraform.tfvars
}

variable "sns_topic_name" {
  description = "Name for the SNS topic used for alarm notifications"
  type        = string
  default     = "cloudwatch-alerts"
}

# ─── CloudWatch Alarms ────────────────────────────────────────────────────────

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the alarm (0–100)"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 1 and 100."
  }
}

variable "error_alarm_threshold" {
  description = "Number of application errors that triggers the alarm"
  type        = number
  default     = 5
}

variable "alarm_evaluation_periods" {
  description = "Number of consecutive periods before an alarm fires"
  type        = number
  default     = 2
}

variable "alarm_period_seconds" {
  description = "Period in seconds for each evaluation window"
  type        = number
  default     = 300 # 5 minutes
}

# ─── EC2 / Application ───────────────────────────────────────────────────────

variable "ec2_instance_id" {
  description = "EC2 instance ID to monitor (used in dashboard & alarms)"
  type        = string
  default     = "i-0123456789abcdef0" # Replace with real instance ID
}

variable "log_group_name" {
  description = "CloudWatch Log Group name for application logs"
  type        = string
  default     = "/ec2/application/logs"
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch Logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention value."
  }
}

# ─── CloudTrail / S3 ─────────────────────────────────────────────────────────

variable "cloudtrail_s3_bucket_name" {
  description = "Globally unique S3 bucket name for CloudTrail logs"
  type        = string
  # Recommended pattern: <org>-cloudtrail-logs-<account_id>
}

variable "enable_s3_access_logging" {
  description = "Enable S3 server-access logging for the CloudTrail bucket"
  type        = bool
  default     = true
}

# ─── Dashboard ───────────────────────────────────────────────────────────────

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard"
  type        = string
  default     = "infrastructure-monitoring"
}
