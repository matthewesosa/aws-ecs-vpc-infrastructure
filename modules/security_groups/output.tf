output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "iccsdb_sg_id" {
  value = aws_security_group.iccsdb_sg.id
}

output "cron_jobs_sg_id" {
  value = aws_security_group.cron_jobs_sg.id
}


output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "efs_sg_id" {
  value = aws_security_group.efs_sg.id
}

output "vpc_endpoint_sg_id" {
  value = aws_security_group.vpc_endpoint_sg.id
}
 