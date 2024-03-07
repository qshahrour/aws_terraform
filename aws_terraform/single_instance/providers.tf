# Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region        = var.region
    profile       = var.profile
}


# Outputs
output "instance_public_ip" {
  value         = aws_instance.web[*].public_ip
  description   = "EC2 instance 01 Public IP"
}

output "instance_tags" {
  value         = aws_instance.web[*].tags
}

output "alb_dns" {
  value         = format("%s%s","http://",aws_lb.alb01.dns_name)
}
