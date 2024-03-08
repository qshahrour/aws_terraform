
resource "" "name" {

}
# Networking
resource "aws_route_table_association" "rtb" {
    subnet_id      = aws_subnet.var.subnet.vpc_id
    route_table_id = aws_route_table.var.rtb.id
}


locals {
    amazon_ami_by_region = {
        "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
        "us-east-2" = "ami-0233c2d874b811deb", # Ohio
        "us-west-1" = "ami-0ed05376b59b90e46", # N. California
        "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
    }
}

# Security Group
resource "aws_security_group" "sg" {
    vpc_id              = aws_vpc.var.vpc_name.id
    name                = var.vpc_name
    ingress {
        description         = "Allow Port 22"
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = [aws_subnet.subnet.cidr_block, "190.86.109.131/32"]
  }
    ingress {
        description         = "Allow port HTTP"
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]

  }
    ingress {
        description         = "Allow ICMP"
        from_port           = -1
        to_port             = -1
        protocol            = "icmp"
        cidr_blocks         = [aws_subnet.subnet.cidr_block, "190.86.109.131/32"]
  }
    egress {
        description         = "Allow All for Egress"
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    tags = {
        Name        = "allow-ssh-http"
        Description = "sg"
     }
}

# Instances
# custo interface with static IP
resource "aws_network_interface" "ni01" {
    subnet_id       = aws_subnet.subnet.vpc_id
    security_groups = [sg.default.id]
    private_ips     = ["10.0.1.4"]
    tags = {
        Name = "Primary Network Interface"
    }
}

# Intance with custom network interface
resource "aws_instance" "Instance" {
    ami                 = var.ami_id.amazon.id # "var.ubuntu_image"
    instance_type       = var.instance_type
    network_interface {
        network_interface_id = aws_network_interface.ni01.id
        device_index         = 0
    }
    key_name        = "awskey"
    tags = {
        Name        = "ec2.container.host"
        OS          = "Amazon Linux 2 AMI x86"
    }
}

resource "aws_instance" "server" {
    ami                         = var.aws_ami.amazon.id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet.id     
    vpc_security_group_ids      = [aws_security_group.sg.id]
  # this provocate always recreate
    #vpc_security_group_id = [aws_security_group.sg.id]
    key_name = ""
    tags = {
        Name = "ec2-tf" 
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


########################
## output   =   =>
########################
output "aws_instance_public_ip" {
    value       = aws_instance.instance.public_ip
    description = "EC2 instance 01 Public IP"
}

output "aws_instance_public_ip" {
    value       = aws_instance.server.public_ip
    description = "EC2 instance 02 Public IP"
}

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
    ami             = data.aws_ami.amazon.id
    instance_type   = var.instance_type
}

locals {
    amazon_ami_by_region = {
        "us-east-1" = "ami-0dc2d3e4c0f9ebd18", # N. Virginia
        "us-east-2" = "ami-0233c2d874b811deb", # Ohio
        "us-west-1" = "ami-0ed05376b59b90e46", # N. California
        "us-west-2" = "ami-0dc8f589abe99f538", # Oregon
    }
}

# Networking
# ----------------------------
resource "aws_vpc" "vpc_name" {
    cidr_block                = var.vpc_cidr
    enable_dns_support        = true
    enable_dns_hostnames      = true
    tags = {
        Name = var.vpc_name
    }
}

#   Subnet: public subnets
resource "aws_subnet" "subnet" {
    count                   = length(var.subnet.cidr)
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.subnet.cidr[count.index]
    map_public_ip_on_launch = true
    availability_zone       = var.public_azs[count.index]
    tags = {
        Name = format("%s%s", var.name_prefix, count.index)
    }
}

#   Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id              = aws_vpc.vpc_name.id
    tags = {
        Name = var.igw.id
    }
}

#   Routing table
resource "aws_route_table" "rtb" {
    vpc_id              = var.vpc_id
    route {
        cidr_block      = "0.0.0.0/0"
        gateway_id      = aws_internet_gateway.igw.id
    }
    tags = {
        Name = var.rtb
    }
}

resource "aws_route_table_association" "rta" {
    count                   = length(var.public_subnet.cidr)
    subnet_id               = var.public_subnet[count.index].id
    route_table_id          = aws_route_table.rtb.id
}

#   Security Group
resource "aws_security_group" "sg" {
    vpc_id                  = var.vpc_id
    name                    = var.sg.id

    dynamic "ingress" {
        for_each = var.sg.id
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
    tags = var.sg.id
}

# Instances
# ----------------------------
variable "ebs_size" {
    type        = string
    default     = "100" 
}
resource "aws_ebs_volume" "volume" {
    count               = length(var.public_azs)
    availability_zone   = var.public_azs[count.index]
    size                = var.ebs_size
    tags = {
        Name = format("%s%s", "vol-tf-", count.index)
    }
}

resource "aws_instance" "web" {
    count                       = length(var.public_subnet.cidr)
    instance_type               = var.default.instance_type
    subnet_id                   = var.public_subnet[count.index].id
    ami                         = local.amazon_ami_by_region[var.region]
    vpc_security_group_ids      = [aws_securitiy_group.sg.id]
    key_name                    = var.default.instance_key_name
    user_data                   = templatefile("user_data.tftp", { server_number = count.index + 1 })
    tags = merge(
        var.default_instance_os_tag,
    {
        Name = "ec2-tf-web-${count.index + 1}"
    })
}

resource "aws_volume_attachment" "ebs_attch" {
    count          = length(aws_ebs_volume.volume[*].id)
    device_name     = "/dev/sdh"
    volume_id       = aws_ebs_volume.volume[count.index].id
    instance_id     = aws_instance.web[count.index].id
}

# Load Balancer
# ----------------------------
# Create a new load balancer
resource "aws_lb" "alb" {
    name               = var.alb_name.id
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg.id]
    subnets            = var.subnet.*.id
    tags = {
        Name = "alb_name"
    }
}

resource "aws_lb_target_group" "tg" {
    name                = var.alb_name.tg
    port                = 80
    protocol            = "HTTP"
    vpc_id              = var.vpc_id
}

resource "aws_lb_target_group_attachment" "tga" {
    count                   = length(aws_instance.web[*].id)
    target_group_arn        = aws_lb_target_group.tg.arn
    target_id               = aws_instance.web[count.index].id
    port                    = 80
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn       = var.alb_name.id
    port                    = "80"
    protocol                = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}
