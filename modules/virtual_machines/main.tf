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
  count         = 2
  ami           = "ami-0de02246788e4a354"
  instance_type = "t2.micro"
  key_name      = "custom_key"
  #subnet_id      = var.priv_sub_3a_id
  subnet_id       = element([var.priv_sub_3a_id, var.priv_sub_4b_id], count.index)
  security_groups = [var.cron_jobs_sg_id]

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