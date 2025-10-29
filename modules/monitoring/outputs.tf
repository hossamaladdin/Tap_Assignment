output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.rds.dashboard_name
  description = "Name of the CloudWatch dashboard"
}

output "alarm_arns" {
  value = {
    cpu_high           = aws_cloudwatch_metric_alarm.cpu_high.arn
    memory_low         = aws_cloudwatch_metric_alarm.memory_low.arn
    storage_low        = aws_cloudwatch_metric_alarm.storage_low.arn
    connections_high   = aws_cloudwatch_metric_alarm.connections_high.arn
    read_latency_high  = aws_cloudwatch_metric_alarm.read_latency_high.arn
    write_latency_high = aws_cloudwatch_metric_alarm.write_latency_high.arn
  }
  description = "Map of alarm names to ARNs"
}
