locals {
  environment = terraform.workspace
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = "${var.vpc_name}-${local.environment}"
  cidr = var.vpc_cidr

  azs                     = var.azs
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  enable_nat_gateway      = true
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true

  tags = {
    Environment = local.environment
  }
}

module "security" {
  source   = "./modules/security"
  sg_name = "${var.name_ecs}-${local.environment}"
  app_port = 80
  vpc_id   = module.vpc.vpc_id
}

module "ecs_app" {
  source                       = "./modules/ecs"
  name_ecs                     = "${var.name_ecs}-${local.environment}"
  ec2_task_execution_role_name = "EcsTaskExecutionRoleName"
  ecs_auto_scale_role_name     = "EcsAutoScaleRoleName"
  app_image                    = "wordpress:latest"
  app_port                     = 80
  app_count                    = 1
  health_check_path            = "/"
  fargate_cpu                  = 1024
  fargate_memory               = 2048
  aws_region                   = var.region
  az_count                     = "2"
  subnets                      = module.vpc.public_subnets
  sg_ecs_tasks                 = [module.security.ecs_tasks_security_group_id]
  vpc_id                       = module.vpc.vpc_id
  lb_security_groups           = [module.security.alb_security_group_id]
  db_host                      = module.rds.rds_endpoint
}


module "logs" {
  source            = "./modules/logs"
  log_group_name    = "/ecs/${var.name_ecs}-${local.environment}"
  log_stream_name   = "ecs-log-${var.name_ecs}-${local.environment}-stream"
  retention_in_days = 30
}



module "rds" {
  source     = "./modules/rds"
  depends_on = [module.vpc.vpc_id]
  environment = local.environment
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id
  ecs_tasks_security_group_id = module.security.ecs_tasks_security_group_id
  name_rds   = "${var.name_rds}-${local.environment}"
}


# module "s3" {
#   source = "./modules/s3_img"
#   bucket_name = "bucket-image-codewithmuh-454"
# }