resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.instance_name}-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"

  dimensions = {
    InstanceId = var.instance_id
  }
}

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "${var.instance_name}-dashboard"

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
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id],
            ["AWS/EC2", "MemoryUtilization", "InstanceId", var.instance_id],
            ["AWS/EC2", "DiskReadBytes", "InstanceId", var.instance_id],
            ["AWS/EC2", "DiskWriteBytes", "InstanceId", var.instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "${var.instance_name} Metrics"
        }
      }
    ]
  })
}
