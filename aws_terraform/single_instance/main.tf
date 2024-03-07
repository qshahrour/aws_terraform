


resource "" "name" {

}
# Networking

resource "aws_route_table_association" "sub1_ass" {
    subnet_id      = aws_subnet.var.subnet.id
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
        cidr_blocks = [aws_subnet.subnet.cidr_block, "190.86.109.131/32"]
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
        cidr_blocks = [aws_subnet.subnet.cidr_block, "190.86.109.131/32"]
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
    security_groups = [aws_security_group.default.id]
    private_ips     = ["10.0.1.4"]
    tags = {
      Name = "Primary Network Interface"
    }
}

# Intance with custom network interface
resource "aws_instance" "instance_name" {
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

resource "instance" "" {
    ami                    = var.ami.id
    instance_type          = var.instance_type
    subnet_id              = aws_vpc.public_subnets.id
    vpc_security_group_ids = [aws_security_group.security_groups.id]
  # this provocate always recreate
    #vpc_security_group_id = [aws_security_group.sg.id]
    key_name = ""
    tags = {
        Name = "ec2-tf-server-02"
        OS   = "Amazon Linux 2 AMI x86"
    }
}

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


######
## output   =   =>

output "instance_public_ip" {
    value       = aws_instance.instance_name.public_ip
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

data "aws_ami" "amazon" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-2.0.*"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "public"
        values = ["true"]
    }
}

resource "aws_instance" "instance" {
    ami           = data.aws_ami.amazon.id
    instance_type = "t2.micro"
}

locals {
    amazon_ami_by_regions = {
        "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
        "us-east-2" = "ami-0233c2d874b811deb", # Ohio
        "us-west-1" = "ami-0ed05376b59b90e46", # N. California
        "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
    }
}

# Networking
# ----------------------------
resource "aws_vpc" "main_vpc" {
    cidr_block                = var.vpc_cidr
    enable_dns_support        = true
    enable_dns_hostnames      = true
    tags = {
        Name = var.vpc_name
    }
}

#   Subnet: public subnets
resource "aws_subnet" "sn" {
    count                   = length(var.public_subnets_cidr)
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnets_cidr[count.index]
    map_public_ip_on_launch = true
    availability_zone       = var.public_azs[count.index]
    tags = {
        Name = format("%s%s", var.name_prefix, count.index)
    }
}

#   Gateway
resource "aws_internet_gateway" "ig01" {
    vpc_id = aws_vpc.vpc_name.id
    tags = {
        Name = var.igw
    }
}

#   Routing table
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.vpc_name.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = var.rtb
    }
}

resource "aws_route_table_association" "rta" {
    count          = length(var.public_subnets_cidr)
    subnet_id      = aws_subnet.subnet[count.index].id
    route_table_id = aws_route_table.rt01.id
}

#   Security Group
resource "aws_security_group" "security_group_id" {
    vpc_id = aws_vpc.main_vpc.id
    name   = var.security_group_id

    dynamic "ingress" {
        for_each = var.sgingress
        content {
            description = ingress.value.description
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }
    egress {
        description = "Allow all for egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = var.securitiy_groups_id
}

# Instances
# ----------------------------
resource "aws_ebs_volume" "volumr" {
    count             = length(var.public_azs)
    availability_zone = var.public_azs[count.index]
        size              = var.ebs_size
    tags = {
        Name = format("%s%s", "vol-tf-", acount.index)
    }
}

resource "aws_instance" "web" {
    count                  = length(var.public_subnets_cidr)
    instance_type          = var.default.instance_type
    subnet_id              = aws_subnet.sn[count.index].id
    ami                    = local.amazon_ami_by_regions[var.region]
    vpc_security_group_ids = [aws_securitiy_group.sg01.id]
    key_name               = var.default.instance_key_name
    user_data              = templatefile("user_data.tftpl", { server_number = count.index + 1 })
    tags = merge(
        var.default_instance_os_tag,
        {
        Name = "ec2-tf-web-${count.index + 1}"
}

resource "aws_volume_attachment" "ebs_att" {
    count       = length(aws_ebs_volume.vol[*].id)
    device_n    ame = "/dev/sdh"
    volume_id   = aws_ebs_volume.vol[count.index].id
    instance_id = aws_instance.web[count.index].id
}

# Load Balancer
# ----------------------------
# Create a new load balancer
resource "aws_lb" "alb01" {
    name               = var.alb_name
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg01.id]
    subnets            = aws_subnet.sn.*.id
    tags = {
        Name = var.alb_name
    }
}

resource "aws_lb_target_group" "tg01" {
    name     = var.alb_tg_name
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc01.id
}

resource "aws_lb_target_group_attachment" "tga01" {
    count            = length(aws_instance.web[*].id)
    target_group_arn = aws_lb_target_group.tg01.arn
    target_id        = aws_instance.web[count.index].id
    port             = 80
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.alb01.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg01.arn
    }
}
