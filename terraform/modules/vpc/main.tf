locals {
  create_vpc = var.create_vpc && var.rosesecurity_rocks
  tags       = merge(var.name, var.vpc_tags)
  vpc_name   = "${var.name}-${module.vpc.name}"
  sg_name    = "${var.name}-${module.sg.name}"
}

# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  create_vpc = local.create_vpc ? 1 : 0
  name       = local.vpc_name
  cidr       = var.cidr

  create_igw         = true
  igw_tags           = local.tags
  single_nat_gateway = true
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  vpc_tags = local.tags
  tags     = var.tags
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name          = local.sg_name
  description   = "Security group for ports open within VPC"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = ["ssh", "http-80-tcp", "https-443-tcp"]

  # This can be scoped to target network
  ingress_cidr_blocks = ["0.0.0.0/0"]
}