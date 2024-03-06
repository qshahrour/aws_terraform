
module "networking" {
    source =  required_providers = {
    
    }
}


provider "aws" {
    region = "var.main_region" # Virginia
}
resource "" "name" {

}
# Networking

resource "aws_route_table_association" "sub1_ass" {
    subnet_id      = aws_subnet.var.zonea_subnet.id
    route_table_id = aws_route_table.var.main_rtbc.id
}


locals {
    amazon_ami_by_regions = {
        "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
        "us-east-2" = "ami-0233c2d874b811deb", # Ohio
        "us-west-1" = "ami-0ed05376b59b90e46", # N. California
        "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
    }
}

# Security Group
resource "aws_security_group" "http-sg" {
    vpc_id = aws_vpc.var.frank_vpc.id
    name   = ""
    ingress {
        description = "Allow Port 22"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [aws_subnet.zonea_subnet.cidr_block, "190.86.109.131/32"]
  }
    ingress {
        description = "Allow port HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

  }
    ingress {
        description = "Allow ICMP"
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = [aws_subnet.zonea_subnet.cidr_block, "190.86.109.131/32"]
  }
    egress {
        description = "Allow All for Egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
    Name        = "sg01-tf-allow-ssh-http"
    Description = "http-sg"
  }
}

# Instances

# custo interface with static IP
resource "aws_network_interface" "ni01" {
    subnet_id       = aws_subnet.sn01.id
    security_groups = [aws_security_group.sg01.id]
    private_ips     = ["10.0.1.4"]
    tags = {
      Name = "Primary Network Interface"
    }
}

# Intance with custom network interface
resource "aws_instance" "container_instance" {
    ami           = "var.ubuntu_image"
    instance_type = "t2.micro"
    network_interface {
        network_interface_id = aws_network_interface.ni01.id
        device_index         = 0
    }
    key_name = "myawskey"
    tags = {
        Name = "ec2.container.host"
        OS   = "Amazon Linux 2 AMI x86"
    }
}

#resource "aws_instance" "" {
#    ami                    = "ami-0dc2d3e4c0f9ebd18"
#  instance_type          = "t2.micro"
#  subnet_id              = aws_subnet.sn01.id
#  vpc_security_group_ids = [aws_security_group.sg01.id]
  # this provocate always recreate
  #  vpc_security_group_ids = [aws_security_group.sg.id]
  #key_name = "Frankfurt_key"
  #tags = {
  #  Name = "ec2-tf-server-02"
  #  OS   = "Amazon Linux 2 AMI x86"
  #}
#}

# Instance with default vpc and default security group
#resource "aws_instance" "instance03" {
##  instance_type = "t2.micro"
  # InvalidGroup.NotFound: You have specified two resources that belong to different networks.
  #  vpc_security_group_ids = [aws_security_group.sg01.id]

  # no accesible via ssh
  #key_name = "myawskey"
  #tags = {
  #  Name = "ec2-tf-server-03"
  #  OS   = "Amazon Linux 2 AMI x86"
  #}
#}


output "instance_public_ip" {
    value       = aws_instance.container_instance.public_ip
    description = "EC2 instance 01 Public IP"
}

#output "instance_02_public_ip" {
#  value       = aws_instance.instance02.public_ip
#  description = "EC2 instance 02 Public IP"
#}

#output "instance_03_public_ip" {
#  value       = aws_instance.instance03.public_ip
#  description = "EC2 instance 03 Public IP"
#}
