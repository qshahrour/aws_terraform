
resource "aws_instance" "vpc_name" {
    ami.id            = var.ami_id
    instance_type     = var.instance_type
    tags = {
        Name = "ultimate-tf"
    }
}

resource "aws_key_pair" "workshop" {
    key_name   = format("%s-workshop",data.aws_ssm_parameter.ami.id.value)
    public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_region" "default" {
    eval source "./instanc.sh" && 
}

resource "aws_eip" "ip_address" {
    instance  = aws_instance.ultimate.id
    vpc       = true
    tags = {
      Name = "ultimate-EIP-tf "
    }   
}


# OUTPUTS
output "ip_address" {
  value       = aws_instance.ultimate.public_ip
  description = "Instance IP Address"
}

output "eip_ip_address" {
  description = "Elastic IP Address"
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
    vpc_id        = var.vpc_id
    tags          = {
        Name      = ""
    }
}

resource "aws_route_table" "rtb" {
    vpc_id          = var.vpc_id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "default-rtb"
    }
}

resource "aws_route_table_association" "rta" {
    subnet_id           = aws_subnet.subnet.id
    route_table_id      = aws_route_table.rtb.id
}


########################################
##          Security Group            ##
########################################
resource "aws_security_group" "default" {
    vpc_id          = var.vpc_id
    name            = "sg"
    ingress {
        description     = "Allow port 22"
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = [aws_subnet.subnet_id.cidr_block, "190.86.109.131/32"]
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

# Instances
# custo interface with static IP
resource "aws_network_interface" "subnet_name" {
    subnet_id           = aws_subnet.subnet_name.id
    security_groups     = [aws_security_group.security_group.id]
    private_ips         = ["10.0.1.4"]
    tags = {
        Name = "Primary Network Interface"
    }
}

# Intance with custom network interface
resource "aws_instance" "ultimate" {
    ami_id                  = var.ami_name.amazon.id
    instance_type           = var.instance_type
    network_interface {
        network_interface_id    = aws_network_interface.ni01.id
        device_index            = 0
    }
    key_name = "awskey"
    tags = {
        Name = "ec2-tf"
        OS   = "Amazon Linux 2 AMI x86"
    }
}

resource "aws_instance" "meduim" {
    ami                       = var.ami_name.id
    instance_type             = var.instance_type
    subnet_id                 = aws_subnet.subnet_name.id
    vpc_security_group_ids    = [aws_security_group.sg.id]

  # this provocate always recreate
  #  vpc_security_group_ids = [aws_security_group.sg01.id]
    key_name = "awskey"
    tags = {
        Name = "meduim-tf"
        OS   = "Amazon Linux 2 AMI x86"
    }
}

# Instance with default vpc and default security group
resource "aws_instance" "standard" {
    ami_id                = var.ami_name.amazon.id
    instance_type         = var.instance_type
    # InvalidGroup.NotFound: You have specified two resources that belong to different networks.
    #  vpc_security_group_ids = [aws_security_group.sg01.id]

    # no accesible via ssh
    key_name = "awskey"
    tags = {
        Name = "standard-tf"
        OS   = "Amazon Linux 2 AMI x86"
    }
}


output "unlimited_public_ip" {
  value           = aws_instance.unlimited.public_ip
  description     = "EC2 instance 01 Public IP"
}

output "meduim_public_ip" {
  value           = aws_instance.meduim.public_ip
  description     = "EC2 instance 02 Public IP"
}

output "standard_public_ip" {
  value           = aws_instance.standard.public_ip
  description     = "EC2 instance 03 Public IP"
}

# References
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
