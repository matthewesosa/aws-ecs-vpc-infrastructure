resource "aws_security_group" "alb_sg" {
  name        = "alb security group"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iccs_alb_sg"
  }
}


# ecs security group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "allow http access on port 80 from alb_sg-(ingress), allow all traffic-(egress)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iccs_ecs_sg"
  }
}


# Security Group for VPC Endpoint to restrict traffic to only ECS tasks (the vpc endpoint is required by ecs since there is no NAT gateway)
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Security group for ECR VPC endpoints"
  vpc_id      = var.vpc_id

  # Allow HTTPS traffic from ECS tasks to the VPC endpoint
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.cron_jobs_sg.id]  # Allow traffic from ECS security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}





# database security group
resource "aws_security_group" "iccsdb_sg" {
  name        = "iccsdb_sg"
  description = "allow ecs access to postgreSQL database on port 5432-(ingress); allow all traffic-(egress)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "postgreSQL access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.cron_jobs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iccsdb_sg"
  }
}

# Security group for bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH from custom network"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from custom network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.custom_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "iccs_bastian_sg"
  }
}

# Security group for cron jobs host
resource "aws_security_group" "cron_jobs_sg" {
  name        = "cron_jobs_sg"
  description = "Allow SSH from Bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "iccs_cron_jobs_sg"
  }
}



# Security Group for EFS allowing access on port 2049 (NFS)
resource "aws_security_group" "efs_sg" {
  name        = "efs_security_group"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  # Allow inbound traffic on port 2049 (NFS) from ECS security group
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.cron_jobs_sg.id] # Allow ECS tasks and cron_jobs_host to mount the EFS # 
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iccs_efs_sg"
  }
}


