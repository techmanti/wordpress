terraform {
  backend "s3" {
    bucket = "terraform-state-wp-techman1"
    key    = "terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "aws_wordpress" {
  source                  = "./modules/wordpress"
  database_name           = var.database_name
  database_user           = var.database_user
  database_password       = var.database_password
  shared_credentials_file = var.shared_credentials_file
  region                  = var.region
  IsUbuntu                = var.IsUbuntu
  AZ1                     = var.AZ1
  AZ2                     = var.AZ2
  AZ3                     = var.AZ3
  VPC_cidr                = var.VPC_cidr
  subnet1_cidr            = var.subnet1_cidr
  subnet2_cidr            = var.subnet2_cidr
  subnet3_cidr            = var.subnet3_cidr
  subnet4_cidr            = var.subnet4_cidr
  PUBLIC_KEY_PATH         = var.PUBLIC_KEY_PATH
  PRIV_KEY_PATH           = var.PRIV_KEY_PATH
  instance_type           = var.instance_type
  instance_class          = var.instance_class
  root_volume_size        = var.root_volume_size
  aws_ami                 = var.aws_ami
  domain_name             = var.domain_name
  record_name             = var.record_name
  alternative_name        = var.alternative_name
  certificate_arn         = module.acm.certificate_arn
}

module "acm" {
  source           = "./modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
}

module "alb" {
  source                = "./modules/alb"
  ec2_security_group_id = module.aws_wordpress.ec2_security_group_id
  public_subnet_az1_id  = module.aws_wordpress.public_subnet_az1_id
  public_subnet_az2_id  = module.aws_wordpress.public_subnet_az2_id
  vpc_id                = module.aws_wordpress.vpc_id
  certificate_arn       = module.acm.certificate_arn
  instance_id           = module.aws_wordpress.instance_id
}

module "router53" {
  source                             = "./modules/router53"
  domain_name                        = var.domain_name
  record_name                        = var.record_name
  aws_lb_target_group_arn            = module.alb.aws_lb_target_group_arn
  application_load_balancer_dns_name = module.alb.application_load_balancer_dns_name
  application_load_balancer_zone_id  = module.alb.application_load_balancer_zone_id
}