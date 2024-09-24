resource "aws_lb" "iccs_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.pub_sub_1a_id, var.pub_sub_2b_id]

  enable_deletion_protection = false


  tags = {
    Name = "${var.project_name}-alb"
  }
}


# ALB Target Groups for path-based routing 

resource "aws_lb_target_group" "xsoap_tg" {
  name     = "iccs-xsoap-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

health_check {
    path                = "/xsoap"       # "/xsoap/health" Ensure the health endpoint is correct
    protocol            = "HTTP"
    #matcher            = "200"
    interval            = 60             # Check every 60 seconds
    timeout             = 10              # Timeout after 10 seconds
    healthy_threshold   = 3              # Mark as healthy after 3 consecutive successes
    unhealthy_threshold = 3              # Mark as unhealthy after 3 consecutive failures
}



}


resource "aws_lb_target_group" "gui_tg" {
  name     = "iccs-gui-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"


  health_check {
      path                = "/gui"         # "/gui/health" Ensure the health endpoint is correct
      protocol            = "HTTP"
      #matcher            = "200"
      interval            = 60             # Check every 60 seconds
      timeout             = 10              # Timeout after 10 seconds
      healthy_threshold   = 3              # Mark as healthy after 3 consecutive successes
      unhealthy_threshold = 3              # Mark as unhealthy after 3 consecutive failures
  }

  stickiness {
      type            = "lb_cookie"       # Use load balancer-generated cookies for stickiness
      cookie_duration = 3600              # Session stickiness for 1 hour (3600 seconds)
  }


}



# alb Listener and listerner rules

resource "aws_lb_listener" "iccs_http_listener" {
  load_balancer_arn = aws_lb.iccs_alb.arn
  port              = "80"
  protocol          = "HTTP"

 # default_action {
    #type             = "forward"
    #target_group_arn = aws_lb_target_group.xsoap_tg.arn
  #}




  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}


resource "aws_lb_listener_rule" "gui_path_routing" {
  listener_arn = aws_lb_listener.iccs_http_listener.arn
  priority     = 100 # Higher priority (evaluated first)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gui_tg.arn
  }
  condition {
    path_pattern {
      values = ["/gui/*", "/gui"]
    }
  }
}


resource "aws_lb_listener_rule" "xsoap_path_routing" {
  listener_arn = aws_lb_listener.iccs_http_listener.arn
  priority     = 200 # Lower priority (evaluated after gui)


  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xsoap_tg.arn
  }
  condition {
    path_pattern {
      values = ["/xsoap/*", "/xsoap"]
    }
  }
}


