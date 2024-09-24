# create vpc endpoints to for ecs to access ecr via AWS privatelink

resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.vpc_endpoint_sg_id]
  subnet_ids          = [var.priv_sub_3a_id, var.priv_sub_4b_id]

}


resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.priv_rt_id]
}


resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg_id]
  subnet_ids          = [var.priv_sub_3a_id, var.priv_sub_4b_id]
}


resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg_id]
  subnet_ids          = [var.priv_sub_3a_id, var.priv_sub_4b_id]
}


resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.vpc_endpoint_sg_id]
  subnet_ids          = [var.priv_sub_3a_id, var.priv_sub_4b_id]
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name = "ecs_task_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}


resource "aws_efs_file_system" "efs" {
  creation_token = "iccs-efs"
  encrypted      = true
}

# EFS Mount Targets in each subnet
resource "aws_efs_mount_target" "efs_mt_1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.priv_sub_3a_id
  security_groups = [var.efs_sg_id]
}

resource "aws_efs_mount_target" "efs_mt_2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.priv_sub_4b_id
  security_groups = [var.efs_sg_id]
}

resource "aws_ecs_cluster" "iccs_cluster" {
  name = "iccs-ecs-cluster"
}

resource "aws_ecs_task_definition" "xsoap_task" {
  family                   = "xsoap-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "xsoap-container"
    image     = var.ecr_xsoap_image_url 
    essential = true

    cpu       = 256
    memory    = 512

    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    mountPoints = [{
      sourceVolume  = "efs-volume"
      containerPath = "/mnt/data"  # /opt/iccs
    }]
  }])

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory          = "/"
    }
  }

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}


resource "aws_ecs_service" "xsoap_service" {
  name            = "xsoap-service"
  cluster         = aws_ecs_cluster.iccs_cluster.id
  task_definition = aws_ecs_task_definition.xsoap_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [var.priv_sub_3a_id, var.priv_sub_4b_id]
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.xsoap_tg_arn
    container_name   = "xsoap-container"
    container_port   = 80
  }
}



resource "aws_ecs_task_definition" "gui_task" {
  family                   = "gui-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "gui-container"
    image     = var.ecr_gui_image_url
    essential = true

    cpu       = 256
    memory    = 512

    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    mountPoints = [{
      sourceVolume  = "efs-volume"
      containerPath = "/mnt/data"   # /opt/iccs
    }]
  }])

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory          = "/"
    }
  }

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "gui_service" {
  name            = "gui-service"
  cluster         = aws_ecs_cluster.iccs_cluster.id
  task_definition = aws_ecs_task_definition.gui_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [var.priv_sub_3a_id, var.priv_sub_4b_id]
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.gui_tg_arn
    container_name   = "gui-container"
    container_port   = 80
  }
}



