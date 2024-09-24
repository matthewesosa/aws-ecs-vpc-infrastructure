output "iccs_alb_arn" {
  value = aws_lb.iccs_alb.arn
}

output "iccs_alb_dns_name" {
  value = aws_lb.iccs_alb.dns_name
}

output "http_listener_arn" {
  value = aws_lb_listener.iccs_http_listener.arn
}

output "xsoap_tg_arn" {
  value = aws_lb_target_group.xsoap_tg.arn
}

output "gui_tg_arn" {
  value = aws_lb_target_group.gui_tg.arn
}

output "alb_sg_id" {
  value = aws_lb.iccs_alb.security_groups
}
