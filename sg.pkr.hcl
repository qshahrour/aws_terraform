########################################
##          Security Group            ##
########################################

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "az" {
    state = "available"
}

resource "aws_vpc" "vpc" {
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.0.0.0/22"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags = {
        "Name" = format("eks-%s-cluster", data.aws_ssm_parameter.instanc_name.value)
    }
}

data "vpc_id" "subnet_id" {
    vpc_id = data.aws_vpc.vpc_name.id
}

resource "aws_subnet" "public_subnet" {
    depends_on                      = [aws_vpc_ipv4_cidr_block_association.vpc-cidr-assoc]
    assign_ipv6_address_on_creation = false
    availability_zone               = data.aws_availability_zones.az.names[0]
    cidr_block                      = "100.64.0.0/18"
    map_public_ip_on_launch         = false
    tags = {
    "Name"                                                                      = format("i1-%s", data.aws_ssm_parameter.tf-eks-cluster-name.value)
    "kubernetes.io/cluster/${data.aws_ssm_parameter.tf-eks-cluster-name.value}" = "shared"
    "workshop"                                                                  = "subnet-i1"
  }
    vpc_id = aws_vpc.vpc_name.id

    timeouts {}
}

resource "aws_security_group_rule" "sg" {
    
    vpc_name        =   var.vpc_id
    name            =   "sg"
    ingress {
        type                = "ingress"
        description         = "Allow port 22"
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = [aws_vpc.var.vpc_name.cidr_block, "190.86.109.131/32"]
    }
    
    ingress {
        description     = "Allow port HTTP"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]

    }
    ingress {
        description     = "Allow ICMP"
        from_port       = -1
        to_port         = -1
        protocol        = "icmp"
        cidr_blocks     = [aws_subnet.subnet_id.cidr_block, "190.86.109.131/32"]
    }
  
    egress {
        description     = "Allow all for Egress"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    tags = {
        Name            = "allow-ssh-http"
        Description     = "Allow SSH & HTTP"
    }
}
