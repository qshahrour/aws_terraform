

provider "aws" {
    source                      = github.com/hashicorp/aws
    version                     = "= 5.3.0"
    region                      = var.region
    shared_credentials_files    = ["~/.aws/credentials"]
    profile                     = "default"
}  

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_region" "current" {
}

data "amazon-ami" "current" {
    filters = {
            name                =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
            root-device-type    =   "ebs" 
            virtualization-type =   "hvm"
    }
    most_recent     =   true
    #owners          =  "637423636753"
    #imds_support    = "v2.0"
}

data "aws_vpc" "default" {
    default = var.vpc_id == null ? true : false
    id      = var.vpc_id
}
