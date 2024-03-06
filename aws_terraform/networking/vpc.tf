##############################
    ## Networking Module ##
#############################

# owner => 036074917124

################################################################################
# local variables on runtime
################################################################################

locals {
  len_public_subnets       = length(var.public_subnets)
  len_private_subnets      = length(var.private_subnets)
  len_private_database_subnets   = length(var.private_database_subnets)
}

# VPC ID => vpc-0d924ecc9c8e05b86
resource "aws_vpc" "this" {
    cidr_block           = "172.31.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
  }
}


# Subnets
resource "aws_subnet" "var.zonea_subnet" {
    vpc_id                  = aws_vpc.var.vpc_name.id
    cidr_block              = "172.31.16.0/20"
    map_public_ip_on_launch = true
    availability_zone       = "eu-central-1a"
    tags = {
        Name = "sub.frank.a.vpc.1"
    }
}

resource "aws_subnet" "var.zoneb_subnet" {
    count                    = local.len_public_subnets
    
    #availability_zone       = "eu-central-1b"
    availability_zone        = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
    availability_zone_id     = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
    vpc_id                   = aws_vpc.var.vpc_name.id
    #cidr_block              = "172.31.32.0/20"
    cidr_block               = var.public_subnets[count.index]
    map_public_ip_on_launch  = true
    
    tags = {
        Name = "sub.frank.b.vpc.1"
    }
}

resource "aws_subnet" "var.private_subnet" {
    vpc_id            = aws_vpc.this
    cidr_block        = "172.31.0.0/20"
    availability_zone = "eu-central-1c"
    tags = {
        Name = "sub.frank.c.vpc.1"
    }
}

# Interneet Gateway => 
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.var.vpc_name.id
    # state = Attached
    tags = {
        Name = "igw.frank.rtb.1"
    }
}

# Routes & Associated Routes => rtb-01bcf1c28f79555a9
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.var.vpc_name.id #vpc.frank.1
    # main  =   Yes
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
  }

    tags = {
        Name = "rtb.frank.vpc.1"
    }
}

# Explicit subnet associations
resource "aws_route_table_association" "sub1_ass" {
    subnet_id      = aws_subnet.var.zonea_subnet.id
    route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "sub2_ass" {
    subnet_id      = aws_subnet.zoneb_subnet.id
    route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "sub3_ass" {
    subnet_id      = aws_subnet.zonec_subnet.id
    route_table_id = aws_route_table.rtb.id
}

# Security Groups
resource "aws_security_group" "data-sg" {
    name        = "data_security_group"
    description = "Security Group For Terraform"
    vpc_id      = aws_vpc.vae.vpc_name.id
    ingress {
        description = "Allow SSH traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
        description = "allow traffic from TCP/80"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
        description = "allow Internal ICMP"
        from_port   = "-1"
        to_port     = "-1"
        protocol    = "icmp"
        cidr_blocks = ["10.0.0.0/16"]
  }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "data-sg"
  }
}

