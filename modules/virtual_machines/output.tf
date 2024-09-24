output "bastion_host_ids" {
  description = "The IDs of the bastion hosts"
  value       = aws_instance.bastion[*].id
}

output "bastion_host_public_ips" {
  description = "The public IPs of the bastion hosts"
  value       = aws_instance.bastion[*].public_ip
}

output "cron_jobs_host_ids" {
  description = "The IDs of the cron jobs hosts"
  value       = aws_instance.cron_jobs[*].id
}

output "cron_jobs_host_private_ips" {
  description = "The private IPs of the cron jobs hosts"
  value       = aws_instance.cron_jobs[*].private_ip
}

