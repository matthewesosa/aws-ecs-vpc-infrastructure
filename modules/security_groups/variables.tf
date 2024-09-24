variable vpc_id {}
variable "custom_cidr" {
  description = "ip address/range for custom network from which SSH connection is made to bastion host"
  type        = string
}