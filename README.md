# AWS Monitoring & Security Automation — Terraform Project

> Production-ready Infrastructure as Code (IaC) solution for AWS CloudWatch monitoring, log analytics, alarm management, and security automation.  
> Primary Region: ap-south-1 (Mumbai)  
> Billing Metrics Region: us-east-1  

---

# 📌 Project Overview

This project builds a centralized AWS monitoring and security system using Terraform.

It includes:

- Cost Monitoring
- Application Log Monitoring
- Network Performance Monitoring
- Automated Alerts (SNS)
- Threat Detection (GuardDuty)
- Audit Logging (CloudTrail)
- Compliance Monitoring (AWS Config)
- Secure Storage (S3)

All infrastructure is provisioned using Terraform.

---

# 🏗 Architecture Flow

Application → CloudWatch Logs  
→ Log Metric Filter  
→ Custom Metric  
→ CloudWatch Alarm  
→ SNS Topic  
→ Email Notification  

Security Flow:

User/API Activity → CloudTrail → S3  
Resource State Changes → AWS Config  
Threat Detection → GuardDuty  

---

# 📂 Project Structure

```
aws-monitoring/
├── provider.tf
├── variables.tf
├── sns.tf
├── logs.tf
├── alarms.tf
├── dashboard.tf
├── security.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```

---

# 🧩 Step-by-Step Implementation

---

## 🔹 STEP 1 – Configure Provider

- Set AWS region to ap-south-1
- Create billing provider alias for us-east-1
- Set Terraform version constraints
- Configure AWS provider version (~> 5.0)

---

## 🔹 STEP 2 – Create SNS Notification System

1. Create SNS Topic
2. Enable encryption (KMS)
3. Add email subscription
4. Confirm email from inbox

Purpose:
To receive CloudWatch alarm notifications via email.

---

## 🔹 STEP 3 – Setup CloudWatch Log Monitoring

1. Create CloudWatch Log Group
2. Set retention to 30 days
3. Create Metric Filters:

   - ERROR → ApplicationErrorCount
   - CRITICAL → CriticalErrorCount

4. Convert log entries into CloudWatch custom metrics

Purpose:
Automatically detect application failures and critical issues.

---

## 🔹 STEP 4 – Create CloudWatch Alarms

Alarms created:

- CPUUtilization > 80%
- ApplicationErrorCount > 5
- CriticalErrorCount > 0
- NetworkIn spike

Alarm configuration:

- Period: 300 seconds
- Evaluation periods: 2
- treat_missing_data = notBreaching
- Alarm action → SNS topic

Purpose:
Enable automated alerting system.

---

## 🔹 STEP 5 – Create CloudWatch Dashboard

Dashboard contains:

- EC2 CPU graph
- Network In/Out graph
- Application error graph
- Critical log graph
- Billing graph (us-east-1)
- Alarm status widget

Purpose:
Provide centralized real-time monitoring visibility.

---

## 🔹 STEP 6 – Enable Security Services

### GuardDuty

- Enabled
- S3 malware protection
- EBS malware scanning

Purpose:
Threat detection and anomaly detection.

---

### CloudTrail

- Multi-region enabled
- Log file validation enabled
- Integrated with S3
- API tracking enabled

Purpose:
Audit logging and forensic analysis.

---

### AWS Config

- Record all resources
- Include IAM global resources
- Store snapshots in S3

Purpose:
Compliance tracking and configuration history.

---

## 🔹 STEP 7 – Secure S3 Buckets

For CloudTrail and Config:

- Versioning enabled
- Server-side encryption enabled
- Public access blocked
- Lifecycle policies configured

Purpose:
Ensure secure log storage.

---

# 🚀 Deployment Instructions

---

## 1️⃣ Clone Repository

```bash
git clone <repo-url>
cd aws-monitoring
```

---

## 2️⃣ Configure AWS Credentials

Using AWS profile:

```bash
export AWS_PROFILE=my-profile
```

OR

```bash
export AWS_ACCESS_KEY_ID=YOUR_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET
export AWS_DEFAULT_REGION=ap-south-1
```

---

## 3️⃣ Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit file:

- alert_email
- ec2_instance_id
- cloudtrail_s3_bucket_name

⚠ cloudtrail_s3_bucket_name must be globally unique.

---

## 4️⃣ Initialize Terraform

```bash
terraform init
```

---

## 5️⃣ Validate

```bash
terraform validate
```

---

## 6️⃣ Plan

```bash
terraform plan -out=tfplan
```

---

## 7️⃣ Apply

```bash
terraform apply tfplan
```

Confirm with `yes`.

---

## 8️⃣ Confirm SNS Email

Check inbox and confirm subscription.

Without confirmation, alarms will not work.

---

# 🧪 Testing & Verification

---

## Test CPU Alarm

SSH into EC2:

```bash
sudo yum install stress -y
stress --cpu 4 --timeout 600
```

CPU alarm should move to ALARM state.

---

## Test Log Alarm

Publish metric:

```bash
aws cloudwatch put-metric-data \
  --namespace "Custom/Application" \
  --metric-name "ApplicationErrorCount" \
  --value 10 \
  --region ap-south-1
```

Alarm should trigger and send email.

---

## Verify GuardDuty

```bash
aws guardduty list-detectors --region ap-south-1
```

---

## Verify CloudTrail

```bash
aws cloudtrail describe-trails --region ap-south-1
```

---

## Verify AWS Config

```bash
aws configservice describe-configuration-recorder-status --region ap-south-1
```

---

# 🧹 Destroy Infrastructure

```bash
terraform destroy
```

If S3 bucket contains objects:

1. Enable “Show versions”
2. Delete all objects
3. Run destroy again

---

# 🔐 Security Best Practices Applied

- S3 versioning enabled
- Server-side encryption enabled
- Public access blocked
- SNS encrypted with KMS
- Multi-region CloudTrail
- Log validation enabled
- IAM least privilege roles
- No hardcoded credentials
- Terraform state excluded via .gitignore

---

# 🎯 Interview Summary

This project demonstrates how to build a centralized AWS monitoring and security automation system using Terraform. It integrates CloudWatch dashboards, log-based custom metrics, automated alarm notifications via SNS, GuardDuty threat detection, CloudTrail audit logging, and AWS Config compliance tracking following Infrastructure as Code best practices.

---

# 👨‍💻 Author

Rohit Bhusare  
DevOps Engineer  
AWS | Terraform | Monitoring | Security Automation  

---

# 📄 License

MIT License