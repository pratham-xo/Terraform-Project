module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.cidr_block
  public_subnet1_cidr = var.public_subnet1_cidr
  public_subnet2_cidr = var.public_subnet2_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
  db_subnet1_cidr = var.db_subnet1_cidr
  db_subnet2_cidr = var.db_subnet2_cidr
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_sub_ids = [
    module.vpc.aws_public_subnet1,
    module.vpc.aws_public_subnet2
  ]
}

module "ecs" {
  source = "./modules/ecs"
  vpc_id = module.vpc.vpc_id
  private_subnet = module.vpc.aws_private_subnet1
  private_subnet2 = module.vpc.aws_private_subnet2
  target_group_arn = module.alb.target_group_alb
  alb_security_group = module.alb.alb_sg_name
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  db_subnet1 = module.vpc.aws_db_subnet
  db_subnet2 = module.vpc.aws_db_subnet2
  ecs_sg = module.ecs.ecs_sg
  db_username = "admin"
  db_password = "Password123!"
}