#=============================
#   Packer Provisioners
#=============================

packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "profile" {
  default     = "ingot"
}
variable "vpc_id" {
  #default  = "vpc-06668cf85af082456"
  describe  = ""
  default   = []
}
variable "subnet_id" {
  #default     = "subnet-05bb983919aff8851"
}

variable "subnet_id" {
  #vpc_id = data.aws_vpc.vpc_id
}
variable "ami_id" {
  #default     = "ami-04dfd853d88e818e8"   
}

variable "region" {
  #default     = "eu-central-1" 
}

variable "amazon-ami" {
  default     = "current"
}

variable "standardCPUCredit" {
  default     = "50"
}

variable "ami_prefix" {
  type    = string
  default = "packer-linux"
}

local {
  timestamp   = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
}
