# =============================================================================
# dashboard.tf - CloudWatch Dashboard with EC2, Billing & Custom Metrics
# Layout (24-column grid, each unit ≈ 50px wide):
#
#  Row 1 (y=0,  h=6): CPU Utilization (w=12)  | Network In/Out (w=12)
#  Row 2 (y=6,  h=6): App Errors (w=12)       | App Critical (w=12)
#  Row 3 (y=12, h=6): Billing (w=24) — full width
# =============================================================================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-${var.dashboard_name}"

  dashboard_body = jsonencode({
    widgets = [

      # ── Widget 1: EC2 CPU Utilization ──────────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 CPU Utilization (%)"
          view   = "timeSeries"
          stacked = false
          region = var.aws_region
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId", var.ec2_instance_id,
              {
                label = "CPU Utilization"
                color = "#ff7f0e"
              }
            ]
          ]

          yAxis = {
            left = {
              min   = 0
              max   = 100
              label = "Percent"
            }
          }

          annotations = {
            horizontal = [
              {
                label = "Alarm threshold"
                value = var.cpu_alarm_threshold
                color = "#d62728"
              }
            ]
          }
        }
      },

      # ── Widget 2: EC2 Network In / Out ─────────────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Network In / Out (Bytes)"
          view   = "timeSeries"
          stacked = false
          region = var.aws_region
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId", var.ec2_instance_id,
              {
                label = "Network In"
                color = "#1f77b4"
              }
            ],
            [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId", var.ec2_instance_id,
              {
                label = "Network Out"
                color = "#2ca02c"
              }
            ]
          ]

          yAxis = {
            left = {
              min   = 0
              label = "Bytes"
            }
          }
        }
      },

      # ── Widget 3: Application Error Count ─────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Application Error Count"
          view   = "timeSeries"
          stacked = false
          region = var.aws_region
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "Custom/Application",
              "ApplicationErrorCount",
              {
                label = "ERROR"
                color = "#d62728"
              }
            ]
          ]

          annotations = {
            horizontal = [
              {
                label = "Error alarm threshold"
                value = var.error_alarm_threshold
                color = "#9467bd"
              }
            ]
          }
        }
      },

      # ── Widget 4: Application Critical Count ──────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Application Critical Events"
          view   = "timeSeries"
          stacked = false
          region = var.aws_region
          stat   = "Sum"
          period = 300

          metrics = [
            [
              "Custom/Application",
              "ApplicationCriticalCount",
              {
                label = "CRITICAL"
                color = "#8c564b"
              }
            ]
          ]
        }
      },

      # ── Widget 5: AWS Billing EstimatedCharges ─────────────────────────────
      # Billing metrics are ONLY available in us-east-1 — region is overridden here
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          title  = "AWS Estimated Charges (USD)"
          view   = "timeSeries"
          stacked = false
          region = "us-east-1" # Billing metrics live exclusively in us-east-1
          stat   = "Maximum"
          period = 86400 # 24h — billing metric updates once per day

          metrics = [
            [
              "AWS/Billing",
              "EstimatedCharges",
              "Currency", "USD",
              {
                label = "Total Estimated Charges"
                color = "#e377c2"
              }
            ]
          ]

          yAxis = {
            left = {
              min   = 0
              label = "USD"
            }
          }
        }
      },

      # ── Widget 6: Alarm Status Panel ──────────────────────────────────────
      {
        type   = "alarm"
        x      = 0
        y      = 18
        width  = 24
        height = 4

        properties = {
          title = "Alarm Status Overview"
          alarms = [
            aws_cloudwatch_metric_alarm.cpu_high.arn,
            aws_cloudwatch_metric_alarm.app_errors_high.arn,
            aws_cloudwatch_metric_alarm.app_critical_high.arn,
            aws_cloudwatch_metric_alarm.network_in_high.arn,
          ]
        }
      }
    ]
  })
}
