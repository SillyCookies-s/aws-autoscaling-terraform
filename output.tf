output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app_server_alb
}

output "load_balancer_url" {
  description = "URL to access the load balancer"
  value       = "http://${aws_lb.app_server_alb.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_server_tg.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_server_aasg.name
}
