# Terraform configuration
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}

locals {
  amazon_ami_by_regions = {
    "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
    "us-east-2" = "ami-0233c2d874b811deb", # Ohio
    "us-west-1" = "ami-0ed05376b59b90e46", # N. California
    "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"
  # insert the 19 required variables here
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
}
module "sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "4.3.0"
  # insert the 3 required variables here
  name        = "web-server-sg"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  # insert the 10 required variables here
  name           = var.ec2_name
  instance_count = var.ec2_instance_count

  ami                    = local.amazon_ami_by_regions[var.aws_region]
  instance_type          = "t2.micro"
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [module.sg.security_group_id]
  #subnet_id              = module.vpc.outpost_subnets
  subnet_ids = module.vpc.public_subnets
}
