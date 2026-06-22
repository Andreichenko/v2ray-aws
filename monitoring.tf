# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_log_group" {
  provider          = aws.region-common
  name              = "/aws/vpc-flow-logs/xray"
  retention_in_days = 7

  tags = {
    Name = "xray-vpc-flow-logs"
  }
}

# IAM Role for Flow Logs to publish to CloudWatch
resource "aws_iam_role" "flow_log_role" {
  provider = aws.region-common
  name     = "xray-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Flow Logs
resource "aws_iam_role_policy" "flow_log_policy" {
  provider = aws.region-common
  name     = "xray-flow-log-policy"
  role     = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# VPC Flow Log to monitor network traffic
resource "aws_flow_log" "xray_vpc_flow_log" {
  provider                 = aws.region-common
  iam_role_arn             = aws_iam_role.flow_log_role.arn
  log_destination          = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.vpc-central-1.id
  max_aggregation_interval = 60 # Check traffic details every 60 seconds

  tags = {
    Name = "xray-vpc-flow-log"
  }
}

# CloudWatch Dashboard for Xray Traffic Monitoring
resource "aws_cloudwatch_dashboard" "xray_dashboard" {
  provider       = aws.region-common
  dashboard_name = "xray-traffic-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", aws_autoscaling_group.xray-asg.name, { stat = "Sum", period = 300 }],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", aws_autoscaling_group.xray-asg.name, { stat = "Sum", period = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "ASG Aggregate Network Traffic (Bytes)"
          region  = var.region-common
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.xray-asg.name, { stat = "Average", period = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "ASG Average CPU Utilization"
          region  = var.region-common
        }
      }
    ]
  })
}

# SNS Topic for Alarms
resource "aws_sns_topic" "xray_alarms" {
  provider = aws.region-common
  name     = "xray-traffic-alarms"
}

# Alarm: High Network Outbound Traffic (e.g. limit to 50 GB in 5 minutes)
resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  provider            = aws.region-common
  alarm_name          = "high-network-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = 53687091200 # 50 GB in bytes
  alarm_description   = "Alarm when outbound network traffic exceeds 50 GB in a 5-minute period"
  alarm_actions       = [aws_sns_topic.xray_alarms.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.xray-asg.name
  }
}
