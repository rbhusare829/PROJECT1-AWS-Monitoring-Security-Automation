# AWS Monitoring & Security Automation — Terraform Project

> **Production-ready** infrastructure-as-code for AWS CloudWatch monitoring, log analytics, alarm management, and security automation. Deploys to **ap-south-1** (Mumbai) with Billing metrics sourced from **us-east-1**.

---

## Architecture Overview

```
aws-monitoring/
├── provider.tf               # AWS provider (primary + us-east-1 alias for billing)
├── main.tf                   # Locals, data sources
├── variables.tf              # All input variables with validation
├── sns.tf                    # SNS topic + email subscription
├── logs.tf                   # Log Group + Metric Filters (ERROR, CRITICAL)
├── alarms.tf                 # CloudWatch Alarms → SNS
├── dashboard.tf              # CloudWatch Dashboard (6 widgets)
├── security.tf               # GuardDuty + CloudTrail + AWS Config
├── outputs.tf                # Exported values
├── terraform.tfvars.example  # Variable template
└── README.md
```

---

## Resources Deployed

| Category | Resource | Details |
|---|---|---|
| **SNS** | `aws_sns_topic` | KMS-encrypted, email subscription |
| **Logs** | `aws_cloudwatch_log_group` | App logs, 30-day retention |
| **Logs** | `aws_cloudwatch_log_metric_filter` | ERROR + CRITICAL filters → Custom/Application namespace |
| **Alarms** | `aws_cloudwatch_metric_alarm` | CPU >80%, AppErrors >5, CRITICAL >0, NetworkIn >1GB |
| **Dashboard** | `aws_cloudwatch_dashboard` | 6 widgets: CPU, Network, AppErrors, Critical, Billing, Alarm Status |
| **Security** | `aws_guardduty_detector` | S3 + EBS malware protection enabled |
| **Security** | `aws_cloudtrail` | Multi-region, log file validation, CW Logs integration |
| **Security** | `aws_s3_bucket` (×2) | CloudTrail + Config buckets (versioned, encrypted, lifecycle) |
| **Security** | `aws_config_configuration_recorder` | All resources + IAM global resources |

---

## Prerequisites

| Requirement | Minimum Version |
|---|---|
| Terraform | `>= 1.3.0` |
| AWS Provider | `~> 5.0` |
| AWS CLI | `>= 2.x` (for authentication) |
| IAM Permissions | AdministratorAccess or scoped policy (see below) |

### Minimum IAM Permissions

The deploying principal needs at minimum:
- `cloudwatch:*`
- `logs:*`
- `sns:*`
- `guardduty:*`
- `cloudtrail:*`
- `s3:*` (for the CloudTrail/Config buckets)
- `config:*`
- `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PutRolePolicy`

---

## Deployment Steps

### 1. Clone / copy the project

```bash
git clone <your-repo>
cd aws-monitoring
```

### 2. Configure AWS credentials

```bash
# Option A — AWS CLI profile
export AWS_PROFILE=my-prod-profile

# Option B — Environment variables
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-south-1
```

### 3. Create your tfvars file

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set alert_email, ec2_instance_id, cloudtrail_s3_bucket_name
```

> **Important:** `cloudtrail_s3_bucket_name` must be globally unique across all AWS accounts.
> Recommended pattern: `<orgname>-cloudtrail-logs-<account_id>`

### 4. Initialize Terraform

```bash
terraform init
```

Expected output:
```
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installed hashicorp/aws v5.x.x

Terraform has been successfully initialized!
```

### 5. Validate configuration

```bash
terraform validate
```

### 6. Review the plan

```bash
terraform plan -out=tfplan
```

Review the output carefully — verify resource counts and names before applying.

### 7. Apply

```bash
terraform apply tfplan
```

Type `yes` when prompted.

### 8. Confirm email subscription

After `apply`, check the inbox for `alert_email`. Click the **Confirm subscription** link in the AWS SNS email. Without this, alarms will not deliver email notifications.

### 9. Review outputs

```bash
terraform output
```

---

## Verify Deployment

```bash
# Check dashboard URL from outputs
terraform output dashboard_url

# Verify GuardDuty is enabled
aws guardduty list-detectors --region ap-south-1

# Verify CloudTrail
aws cloudtrail describe-trails --region ap-south-1

# Verify Config recorder is running
aws configservice describe-configuration-recorder-status --region ap-south-1

# Test alarm by publishing to the custom metric manually
aws cloudwatch put-metric-data \
  --namespace "Custom/Application" \
  --metric-name "ApplicationErrorCount" \
  --value 10 \
  --region ap-south-1
```

---

## Tear Down

```bash
# Destroy all resources
terraform destroy

# Note: S3 buckets with force_destroy=false will fail to destroy if they contain objects.
# To destroy, either empty the buckets first or temporarily set force_destroy=true.
```

---

## Customization Guide

### Add more EC2 instances to alarms

In `alarms.tf`, duplicate the `cpu_high` resource with a new `ec2_instance_id` dimension.

### Add Slack notification

1. Create an SNS subscription with `protocol = "https"` and the Slack webhook URL via AWS Chatbot.

### Enable CloudTrail data events (S3/Lambda)

Uncomment the `data_resource` block in `security.tf → aws_cloudtrail`.

### Use Customer-Managed KMS Key

Replace `kms_master_key_id = "alias/aws/sns"` in `sns.tf` and `sse_algorithm = "AES256"` in S3 resources with your CMK ARN.

---

## Interview Explanation

### Q: Why is Billing in us-east-1 and not ap-south-1?

AWS CloudWatch Billing metrics (`AWS/Billing`) are a global service and are **only published to us-east-1**. To display them on a dashboard in any other region, you either need a cross-region widget (which CloudWatch dashboards support natively via the `region` property inside a widget) or use the `us-east-1` provider alias. This project handles this by hardcoding `"region": "us-east-1"` inside the Billing dashboard widget.

### Q: Why use `jsonencode()` for the dashboard body?

`jsonencode()` is the idiomatic Terraform way to construct JSON from HCL maps. It avoids escaping issues, allows referencing resource attributes (e.g., alarm ARNs) directly, and keeps the code readable. The alternative — a raw JSON string with `<<EOF` — is error-prone and can't reference Terraform values.

### Q: Why `treat_missing_data = "notBreaching"` on alarms?

For EC2 metrics, missing data usually means the instance is stopped or in a maintenance window — not a real problem. Setting `notBreaching` prevents false alarms during scheduled downtime. For critical health checks you'd use `breaching` instead.

### Q: How does the log metric filter work end-to-end?

```
App writes log → CloudWatch Agent → Log Group → Metric Filter
→ Custom Metric (Custom/Application/ApplicationErrorCount)
→ CloudWatch Alarm evaluates metric every 5 minutes
→ Threshold breached → Alarm publishes to SNS Topic
→ SNS delivers email to subscriber
```

### Q: Why enable `is_multi_region_trail = true`?

A single-region trail misses API calls made in other regions (e.g., IAM calls always go to us-east-1). Multi-region ensures complete audit coverage across the entire account.

### Q: How does AWS Config differ from CloudTrail?

| Feature | CloudTrail | AWS Config |
|---|---|---|
| Records | **API calls** (who did what, when) | **Resource state** (what does it look like now) |
| Use case | Audit, forensics | Compliance, drift detection |
| Temporal | Point-in-time events | Configuration history & diffs |

---

## Security Best Practices Applied

- S3 buckets: versioning, SSE-AES256, public access blocked, lifecycle rules
- SNS topic: KMS encrypted at rest
- CloudTrail: log file validation (SHA-256 digest), CloudWatch Logs integration
- GuardDuty: S3 threat detection + EBS malware scanning enabled
- IAM roles: least-privilege, separate roles for CloudTrail and Config
- Bucket policies: `StringEquals` conditions to restrict to specific trail/account
- No hardcoded credentials — all via provider authentication chain

---

## License

MIT — use freely, no warranty.
