# =============================================================================
# main.tf - Root Configuration
# Wires together all resources defined in dedicated files.
# Actual resource blocks live in: dashboard.tf, logs.tf, alarms.tf,
#                                  sns.tf, security.tf
# =============================================================================

# Retrieve current AWS account information (used in IAM policies & naming)
data "aws_caller_identity" "current" {}

# Retrieve current region (convenience reference)
data "aws_region" "current" {}

# ─── Local Values ─────────────────────────────────────────────────────────────

locals {
  # Consistent name prefix for every resource
  name_prefix = "${var.project_name}-${var.environment}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Region      = local.region
  }
}
