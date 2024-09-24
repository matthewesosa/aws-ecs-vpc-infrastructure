module "vpc" {
  source           = "../modules/vpc"
  region           = var.region
  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  pub_sub_1a_cidr  = var.pub_sub_1a_cidr
  pub_sub_2b_cidr  = var.pub_sub_2b_cidr
  priv_sub_3a_cidr = var.priv_sub_3a_cidr
  priv_sub_4b_cidr = var.priv_sub_4b_cidr
}


module "security_groups" {
  source      = "../modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  custom_cidr = var.custom_cidr
}

module "virtual_machines" {
  source          = "../modules/virtual_machines"
  pub_sub_1a_id   = module.vpc.pub_sub_1a_id
  pub_sub_2b_id   = module.vpc.pub_sub_2b_id #
  priv_sub_3a_id  = module.vpc.priv_sub_3a_id
  priv_sub_4b_id  = module.vpc.priv_sub_4b_id #
  bastion_sg_id   = module.security_groups.bastion_sg_id
  cron_jobs_sg_id = module.security_groups.cron_jobs_sg_id
}


module "database" {
  source          = "../modules/database"
  iccsdb_sg_id    = module.security_groups.iccsdb_sg_id
  priv_sub_3a_id  = module.vpc.priv_sub_3a_id
  priv_sub_4b_id  = module.vpc.priv_sub_4b_id
  iccsdb_username = var.iccsdb_username
  iccsdb_password = var.iccsdb_password
  iccsdb_sub_name = var.iccsdb_sub_name
  iccsdb_name     = var.iccsdb_name
}

module "loadbalancer" {
  source        = "../modules/loadbalancer"
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  alb_sg_id     = module.security_groups.alb_sg_id
  vpc_id        = module.vpc.vpc_id
  project_name  = var.project_name
}


module "ecr" {
  source         = "../modules/ecr"
  ecr_mutability = var.ecr_mutability
}

module "ecs_efs" {
  source              = "../modules/ecs_efs"
  vpc_id              = module.vpc.vpc_id
  vpc_endpoint_sg_id  = module.security_groups.vpc_endpoint_sg_id
  priv_sub_3a_id      = module.vpc.priv_sub_3a_id
  priv_sub_4b_id      = module.vpc.priv_sub_4b_id
  region              = var.region
  priv_rt_id          = module.vpc.priv_rt_id
  efs_sg_id           = module.security_groups.efs_sg_id
  ecs_sg_id           = module.security_groups.ecs_sg_id
  gui_tg_arn          = module.loadbalancer.gui_tg_arn
  xsoap_tg_arn        = module.loadbalancer.xsoap_tg_arn
  ecr_gui_image_url   = var.ecr_gui_image_url
  ecr_xsoap_image_url = var.ecr_xsoap_image_url
}

