terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = terraform.workspace
  
  default_tags {
    tags = {
      Terraform            = "true"
      Environment          = var.environment_type
      environment-type     = var.environment_type
      cost-center          = var.cost_center
      project-name         = var.project_name
      resource-owner       = var.resource_owner
      resource-owner-email = var.resource_owner_email
    }
  }
}
