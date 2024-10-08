# Bastion host in the public subnet
resource "aws_instance" "bastion" {
  count         = 2
  ami           = "ami-0de02246788e4a354"
  instance_type = "t2.micro"
  key_name      = "custom_key"
  #subnet_id      = var.pub_sub_1a_id
  subnet_id       = element([var.pub_sub_1a_id, var.pub_sub_2b_id], count.index)
  security_groups = [var.bastion_sg_id]
  

  #tags = {
  #Name = "bastion_host"
  #}

  tags = {
    Name = "bastion_host ${count.index + 1}"
  }

}

# cron jobs instance in the private subnet(s)
resource "aws_instance" "cron_jobs" {
  count           = 2
  ami             = "ami-0de02246788e4a354"
  instance_type   = "t2.micro"
  key_name        = "custom_key"
  #subnet_id      = var.priv_sub_3a_id
  subnet_id       = element([var.priv_sub_3a_id, var.priv_sub_4b_id], count.index)
  security_groups = [var.cron_jobs_sg_id]
  iam_instance_profile = aws_iam_instance_profile.codeartifact_instance_profile.name   #

  #tags = {
  #Name = "cron_jobs_host"
  #}

  tags = {
    Name = "cron_jobs_host ${count.index + 1}"
  }

  # Use user_data to copy index.txt to the home directory
  user_data = <<-EOF
              #!/bin/bash
              echo "Copying index.txt to the home directory..."
              echo "${file("${path.module}/index.txt")}" > /home/ec2-user/index.txt
              EOF
}


resource "aws_iam_role" "codeartifact_role" {
  name = "${var.project_name}-codeartufact-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codeartifact_access" {
  name   = "codeartifact-access"
  role   = aws_iam_role.codeartifact_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "codeartifact:ListRepositories",
          "codeartifact:ListRepositoriesInDomain",
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository",
          "codeartifact:GetPackageVersionAsset",
          "sts:GetServiceBearerToken"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "codeartifact_instance_profile" {
  name = "codeartifact-instance-profile"
  role = aws_iam_role.codeartifact_role.name
}

# To ensure that all requests from the cron_jobs host to AWS CodeArtifact stay within the AWS network,
# you need to create two VPC Endpoints:

resource "aws_vpc_endpoint" "codeartifact_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.codeartifact.api"  
  vpc_endpoint_type = "Interface"
  
  subnet_ids         = [var.priv_sub_3a_id, var.priv_sub_4b_id]
  security_group_ids = [var.vpc_endpoint_sg_id] 
  
  private_dns_enabled = true  # Enable private DNS to resolve CodeArtifact API endpoints internally
}

resource "aws_vpc_endpoint" "codeartifact_repos" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.codeartifact.repositories" 
  vpc_endpoint_type = "Interface"
  
  subnet_ids         = [var.priv_sub_3a_id, var.priv_sub_4b_id]
  security_group_ids = [var.vpc_endpoint_sg_id] 
  
  private_dns_enabled = true  # Enable private DNS to resolve CodeArtifact repositories
}