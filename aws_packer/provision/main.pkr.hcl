
terraform {
  # specify minimum version of Terraform 
    required_version = "> 1.4.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            #  Lock version to prevent unexpected problems
            version = "4.65.0"
        }
        null = {
            source  = "hashicorp/null"
            version = "~> 3.1.0"
        }
        external = {
            source  = "hashicorp/external"
            version = "~> 2.1.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "2.17.0"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.4.1"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.1.0"
        }

    }
}

# specify local directory for AWS credentials
provider "aws" {
    region                      = var.region
    shared_credentials_files    = ["~/.aws/credentials"]
    profile                     = var.profile
}
provider "null" {}
provider "external" {}

providers   "aws" {
    source                      = github.com/hashicorp/aws
    region                      = var.region
}
provider "aws" {
    vpc_name                    = " hashicorp/aws"
    version                     = "= 5.3.0"
    region                      = var.region
    shared_credentials_files    = ["~/.aws/credentials"]
    profile                     = "default"
    source                      = "../networking"
    
}  

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  default       = false
  id            = data.aws_ssm_parameter.eks-vpc.value
  #filter {
  #  name   = "tag:workshop"
  #  values = ["eks-cicd"]
  #}
}

data "aws_security_group" "cicd" {
  vpc_id = data.aws_vpc.cicd.id
  filter {
    name   = "tag:workshop"
    values = ["eks-cicd"]
  }
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "public_subnet" {
  vpc_id            =data.aws_ssm_parameter.eks-vpc.value
    filter {
    name        = "tag:workshop"
    values      = ["subnet-public"]
  }
}
data "aws_subnet" "cicd" {

  filter {
    name   = "tag:workshop"
    values = ["cicd-private1"]
  }
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
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

data "aws_region" "current" {
}

data "amazon-ami" "current" {
    filters = {
        name                =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
        root-device-type    =   "ebs" 
        virtualization-type =   "hvm"
    }
    most_recent     =   true
    owners          =  "637423636753"
    #imds_support    = "v2.0"
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
}       root-device-type  == null ? true : false
        ami_id  = var.vpc_name(name)
}


shared_credentials_files    = ["~/.aws/credentials"]
    profile                     = "default"
}  


# Networking
resource "aws_vpc" "vpc" {
    cidr_block           = "10.100.10.0/24"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "Infra_VPC_Frankfurt"
    }
}

resource "aws_subnet" "public_subnets" {
    vpc_id                  =   aws_vpc.vpc_name.id
    cidr_block              =   aws_vpc.var.cidr_block
    map_public_ip_on_launch =   true
    availability_zone       =   var.aws_region
    tags = {
        Name = "public-subnet-tf"
    }
}


resource "aws_internet_gateway" "igw" {
    vpc_id        = aws_vpc.vpc_name.id
    tags          = {
        Name      = ""
    }
}


resource "aws_route_table" "rtb" {
    vpc_id          = aws_vpc.vpc_name.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "default-rtb"
    }
}

resource "aws_route_table_association" "rtb" {
    subnet_id           = aws_subnet.association.id
    route_table_id      = aws_route_table.rtb.id
}
