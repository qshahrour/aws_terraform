###############################################
# => Defining Plugins

packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

#############################################
## => Defining Variables
#############################################

variable "profile" {
  default         = "ingot"
}
variable "vpc_id" {
  #default  = "vpc-06668cf85af082456"
  type            = string
  default         = "current"
}
variable "subnet_id" {
  default         = "subnet-05bb983919aff8851"
}

variable "ami_id" {
  type            = string
  default         = "ami-04dfd853d88e818e8"   
}

variable "region" {
  default         = "eu-central-1" 
}

variable "amazon-ami" {
  default         = "current"
}

variable "instance_type" {
  type            = string
  default         = "t3.xlarge"
}

variable "unlimitedCPUCredit" {
  default         = []
}

variable "standardCPUCredit" {
  default         = []
}

variable "ssh_user" {
  type            = string
  default         = "ubuntu"
}

variable "app_name" {
  type            = string
  default         = "httpd"
}

###########################################
locals {
  app_name        = "httpd"
}

locals {
  ami_name        = "${var.app_name}-prodcution"
  timestamp       = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
} 

//local "secret_key" {
//  key             = "${var.secret_key}"
//  sensitive       = true
//}
###########################################
#source_ami          = "${var.ami_id}"

variable "script_path" {
  default         = env("SCRIPT_PATH")
}

########################################
# => Writing our Sources

#=> packer build -var 'app_name=httpd' ami.pkr.hcl
#packer build -var-file="vars.packer.hcl"
# => packer build -var-file="vars.packer.hcl"
source "amazon-ebs" "httpd" {   
  ami_name            = "PACKER-DEMO-${local.app_name}"
  instance_type       = "${var.instance_type}"
  region              = "${var.region}"
  source_ami          = "${var.ami_id}"
  ssh_username        = "${var.ssh_user}"
  spot_price          = "auto"
  ssh_wait_timeout    = "10000s"
  skip_create_ami     = true
  tags = {
    Env       = "demo"
    Name      = "packer-demo-${var.app_name}"
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "100G"
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false
  }
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

#########################################
# => Starting our build
########################################
build {
  sources = ["source.amazon-ebs.httpd"]

  provisioner "shell" {
    inline = [
        "apt-get update",
        "apt-get install -y nginx"
    ]
  }

  provisioner "shell" {
    script = "script/install_docker.sh"
  }

  post-processor "shell-local" {
    inline = ["script has been copied to server"]
  }

  provisioner "file" {
    inline = [
      source= ./docker-compose.yaml,
      destination= /home/ubuntu/
    ]
  }

  provisioner "shell" { 
    inline = [
      "ls -al /home/ubuntu",
      "cat /home/ubuntu/docker-compose.yaml"
    ]
  }

    //provisioner "shell" {
  //  script          = "${var.script_path}/demo-script.sh" 
  //}

}

