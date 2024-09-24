output "iccs_alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.loadbalancer.iccs_alb_arn
}

# Reference ALB DNS Name
output "iccs_alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.loadbalancer.iccs_alb_dns_name
}

# Reference ALB HTTP Listener ARN
output "http_listener_arn" {
  description = "The ARN of the HTTP listener for the ALB"
  value       = module.loadbalancer.http_listener_arn
}

# Reference xsoap Target Group ARN
output "xsoap_target_group_arn" {
  description = "The ARN of the Target Group for xsoap"
  value       = module.loadbalancer.xsoap_tg_arn
}

# Reference gui Target Group ARN
output "gui_target_group_arn" {
  description = "The ARN of the Target Group for gui"
  value       = module.loadbalancer.gui_tg_arn
}

# Reference the ALB security group ID
output "alb_sg_id" {
  value = module.loadbalancer.alb_sg_id
}

