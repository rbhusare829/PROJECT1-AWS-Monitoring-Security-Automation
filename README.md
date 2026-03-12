# 🚀 AWS CloudWatch Monitoring & Security Automation

> **Internship Project 1** — Production-ready AWS Monitoring Infrastructure using Terraform (IaC)
> **Deployed by:** Rohit Bhusare | **Region:** ap-south-1 (Mumbai) | **Date:** 02-03-2026

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Summary](#architecture-summary)
3. [Project Structure](#project-structure)
4. [Prerequisites](#prerequisites)
5. [Deployment Steps](#deployment-steps)
6. [Live Implementation Screenshots](#live-implementation-screenshots)
7. [Resources Deployed](#resources-deployed)
8. [Key Learnings & Interview Notes](#key-learnings--interview-notes)
9. [Cleanup](#cleanup)

---

## Project Overview

As part of **Internship Project 1**, I implemented a centralized AWS monitoring solution using **Amazon CloudWatch Dashboards** covering four focus areas:

| # | Focus Area | Services Used |
|---|---|---|
| 1 | **Billing & Cost** | AWS/Billing, CloudWatch (us-east-1) |
| 2 | **Application & System Logs** | CloudWatch Logs, Log Metric Filters |
| 3 | **Network Performance** | EC2 NetworkIn/Out metrics |
| 4 | **Security & Compliance** | GuardDuty, CloudTrail, AWS Config |

All infrastructure is provisioned using **Terraform 1.x** following IaC best practices.

---

## Architecture Summary

```
┌─────────────────────────────────────────────────────────┐
│                  ap-south-1 (Mumbai)                    │
│                                                         │
│  EC2 Instance                                           │
│     │                                                   │
│     ▼ (CloudWatch Agent)                                │
│  CloudWatch Log Group (/ec2/application/logs)           │
│     │                                                   │
│     ▼ (Metric Filter)                                   │
│  Custom Metric (Custom/Application)                     │
│     │                                                   │
│     ▼                                                   │
│  ┌──────────────────────────────────┐                   │
│  │ CloudWatch Alarms (4)            │                   │
│  │ CPU > 80%                        │                   │
│  │ AppErrors > 5                    │                   │
│  │ CRITICAL > 0                     │                   │
│  │ NetworkIn > 1GB                  │                   │
│  └──────────┬───────────────────────┘                   │
│             ▼                                           │
│         SNS Topic ──► Email (rbhusare829@gmail.com)     │
│                                                         │
│  Security Layer:                                        │
│  ├── GuardDuty (Detector ID: 31d270f22...)              │
│  ├── CloudTrail (Multi-region trail → S3)               │
│  └── AWS Config (Recording is ON → S3)                  │
└─────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
aws-monitoring/
│
├── provider.tf               # AWS provider ~>5.0, dual region setup
├── main.tf                   # Locals, data sources
├── variables.tf              # 15 variables with validation blocks
├── dashboard.tf              # CloudWatch Dashboard — 6 widgets (jsonencode)
├── logs.tf                   # Log Group + ERROR/CRITICAL metric filters
├── alarms.tf                 # 4 CloudWatch Alarms → SNS
├── sns.tf                    # KMS-encrypted SNS topic + email subscription
├── security.tf               # GuardDuty + CloudTrail + S3 + AWS Config
├── outputs.tf                # 20+ outputs (ARNs, names, dashboard URL)
├── terraform.tfvars.example  # Template for replication
└── README.md
```

---

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | >= 1.3.0 |
| AWS Provider | ~> 5.0 |
| AWS CLI | >= 2.x |

---

## Deployment Steps

### Step 1 — Configure

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit: alert_email, ec2_instance_id, cloudtrail_s3_bucket_name
```

### Step 2 — Initialize & Apply

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 3 — Verify

```bash
terraform state list
```

### Step 4 — Test CPU Alarm

```bash
ssh -i .\Downloads\ansible.pem ec2-user@<EC2-PUBLIC-IP>
sudo yum install stress -y
stress --cpu 2 --timeout 300
```

---

## Live Implementation Screenshots

### 1. CloudWatch Dashboard

> Dashboard: `aws-monitoring-prod-infrastructure-monitoring` | Region: ap-south-1

![CloudWatch Dashboard](Screenshot%202026-03-02%20101408.png)

**What's visible:**
- ERROR + CRITICAL metric widgets (Custom/Application namespace)
- AWS Estimated Charges (USD) — "No data available" is **expected** — Billing metrics update once per day
- Alarm Status Overview: all 4 alarms ✅ OK

---

### 2. CloudWatch Alarms Overview

> CloudWatch → Overview | EC2: 4 OK | Recent Alarms panel

![CloudWatch Overview](Screenshot%202026-03-02%20101707.png)

**What's visible:**
- EC2 service bar — 0 In Alarm, 0 Insufficient Data, **4 OK** ✅
- `aws-monitoring-prod-cpu-utilization-high` → OK (threshold: CPU > 80%)

---

### 3. Billing Dashboard

> CloudWatch → Billing | EstimatedCharges (us-east-1)

![Billing Dashboard](Screenshot%202026-03-02%20101919.png)

**What's visible:**
- `EstimatedCharges` widget with `region = "us-east-1"`
- "No data available" — expected for new accounts (24h update cycle)

---

### 4. Alarm Status — No Active Alarms

> Recent Alarms → All OK

![Alarm Status](Screenshot%202026-03-02%20101950.png)

**What's visible:**
- No alarms firing — system healthy ✅

---

### 5. All 4 Alarms — OK State

> CloudWatch → Alarms | Filter: State = OK

![All Alarms OK](Screenshot%202026-03-02%20102401.png)

| Alarm Name | State | Condition |
|---|---|---|
| `aws-monitoring-prod-application-critical-high` | ✅ OK | CRITICAL > 0 |
| `aws-monitoring-prod-cpu-utilization-high` | ✅ OK | CPU > 80% |
| `aws-monitoring-prod-application-errors-high` | ✅ OK | AppErrors > 5 |
| `aws-monitoring-prod-network-in-high` | ✅ OK | NetworkIn > 1GB |

---

### 6. SNS Topic & Email Subscription

> SNS → `aws-monitoring-prod-cloudwatch-alerts`

![SNS Topic](Screenshot%202026-03-02%20103216.png)

**What's visible:**
- Topic: `aws-monitoring-prod-cloudwatch-alerts` | Type: Standard
- `rbhusare829@gmail.com` → ✅ **Confirmed**
- KMS encryption enabled (alias/aws/sns)

---

### 7. GuardDuty — Settings

> GuardDuty → Settings | Detector active

![GuardDuty Settings](Screenshot%202026-03-02%20103448.png)

**What's visible:**
- **Detector ID:** `31d270f22ad84adb8120e2834212cc8a`
- S3 Protection + Malware Protection enabled

---

### 8. GuardDuty — Detector Tags

> GuardDuty → Detector Tags | 7 Terraform-managed tags

![GuardDuty Tags](Screenshot%202026-03-02%20103514.png)

| Key | Value |
|---|---|
| Project | aws-monitoring |
| Owner | devops-team |
| ManagedBy | **Terraform** |
| Environment | prod |
| Region | ap-south-1 |
| Purpose | Threat detection |
| Name | aws-monitoring-prod-guardduty |

---

### 9. AWS Config — Recording is ON

> AWS Config → Settings

![AWS Config](Screenshot%202026-03-02%20103719.png)

**What's visible:**
- **Recording is ON** ✅
- S3 bucket: `myorg-cloudtrail-logs-123456789012-config`
- Data retention: 7 years

---

### 10. CloudTrail — Multi-Region Trail

> CloudTrail → Trails

![CloudTrail](Screenshot%202026-03-02%20103914.png)

| Property | Value |
|---|---|
| Trail Name | `aws-monitoring-prod-trail` |
| Multi-region | **Yes** ✅ |
| S3 Bucket | `myorg-cloudtrail-logs-123456789012` |
| Status | **Logging** ✅ |

---

### 11. Terraform State List

> VS Code → `terraform state list` → 32 resources

![Terraform State](Screenshot%202026-03-02%20104051.png)

- All 32 resources deployed successfully ✅

---

### 12. Recent Alarms with Thresholds

> All 4 alarms with red threshold lines

![Recent Alarms](Screenshot%202026-03-02%20111553.png)

- CPU > 80%, NetworkIn > 1.07GB, Errors > 5 — all OK ✅

---

### 13. S3 Bucket — CloudTrail Logs

> S3 → myorg-cloudtrail-logs → AWSLogs/

![S3 CloudTrail](Screenshot%202026-03-02%20112554.png)

- `CloudTrail/` — API event logs ✅
- `CloudTrail-Digest/` — SHA-256 tamper detection ✅

---

### 14. EC2 Stress Test — CPU Alarm Trigger

> SSH → stress --cpu 2 --timeout 300

![Stress Test](Screenshot%202026-03-02%20112612.png)

- `stress` ran 300 seconds → CPU > 80% triggered → SNS → Email delivered ✅

---

## Resources Deployed

| Service | Resource | Count |
|---|---|---|
| CloudWatch | Dashboard + Log Groups + Metric Filters + Alarms | 9 |
| SNS | Topic + Policy + Subscription | 3 |
| GuardDuty | Detector | 1 |
| CloudTrail | Trail | 1 |
| S3 | Buckets + Policies + Config | 10 |
| AWS Config | Recorder + Delivery + Status | 3 |
| IAM | Roles + Policies | 5 |
| **Total** | | **32 resources** |

---

## Key Learnings & Interview Notes

### Why is Billing in us-east-1?
`AWS/Billing` metrics are **only published to us-east-1**. Dashboard widget uses `"region": "us-east-1"` override inside `jsonencode()`.

### Why `treat_missing_data = "notBreaching"`?
When EC2 is stopped, metrics stop coming. `notBreaching` prevents **false alarms** during planned downtime.

### Why `is_multi_region_trail = true`?
IAM calls always route to `us-east-1`. Single-region trail misses them. Multi-region captures all global events.

### CloudTrail Digest Files
`CloudTrail-Digest/` = SHA-256 hash files proving logs were not tampered. Enabled by `enable_log_file_validation = true`.

### AWS Config vs CloudTrail

| | CloudTrail | AWS Config |
|---|---|---|
| Records | API calls (who did what) | Resource state (what does it look like) |
| Use case | Audit & forensics | Compliance & drift detection |

---

## Cleanup

```bash
terraform destroy
# Empty S3 buckets first before destroying
```

---

## 👨‍💻 Author

**Rohit Bhusare**
- AWS Account: `350363534873`
- Region: Asia Pacific (Mumbai) — ap-south-1
- Internship Project 1 — AWS CloudWatch Monitoring & Security Automation
- Completed: 02-03-2026

---

*All infrastructure managed by Terraform. `ManagedBy = Terraform` tag on every resource.*
