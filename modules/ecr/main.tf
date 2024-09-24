resource "aws_ecr_repository" "iccs_dev_xsoap" {
  name                 = "iccs-dev/xsoap"
  image_tag_mutability = var.ecr_mutability ? "MUTABLE" : "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

      tags = {
    Name = "iccs-dev/xsoap"
  }

    #lifecycle {
    #prevent_destroy = true
  #}
}

resource "aws_ecr_repository" "iccs_dev_gui" {
  name                 = "iccs-dev/gui"
  image_tag_mutability = var.ecr_mutability ? "MUTABLE" : "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

      tags = {
    Name = "iccs-dev/gui"
  }

    #lifecycle {
    #prevent_destroy = true
  #}
}