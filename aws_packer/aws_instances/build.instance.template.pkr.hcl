# => CORP01_OS_10.100.63.0/24
# => vpc-06668cf85af082456

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
  
  type      = string
  default     = "current"
}
variable "subnet_id" {
  #default     = "subnet-05bb983919aff8851"
}

#variable "subnet_id" {
  #vpc_id = data.aws_vpc.vpc_id
#}
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

variable "amiprefix" {
  type    = string
  default = "packer-linux"
}

variable "ami_prefix" {
  type    = string
  default = "packer-linux"
}


#locals {
#    timestamp                       = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
#    jammy_destination               = "/home/ubuntu"
#    jammy_start_retry_timeout       = "30m"
#    jammy_attributes                = lookup(local.image_options.native, "attributes", "")
#}

#locals {
#  timestamp   = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
#}


source "amazon-ebs" "standard" {

  ami_name                        = "${var.ami_prefix}-${local.timestamp}"
  instance_type                   = "${var.instance_type}"
  region                          = "${var.region}"
  #ssh_timeout                     = "${var.local.communicator.timeout}"
  ssh_agent_auth                  = "false"
  enable_unlimited_credits        = "true"
  #temporary_key_pair_type        = ["awskey"]  
  skip_create_ami                 = "true"
  ssh_timeout                     = "30m"
  inline                              = ["echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_username}", "chmod 0440 /etc/sudoers.d/99${var.ssh_username}"]
  launch_block_device_mappings {
    device_name                 = "/dev/sda1"
    volume_size                 = "100"
    volume_type                 = "gp3"
    delete_on_termination       = "true"
    encrypted                   = "false"
  }
  source_ami_filter {
    filters = {
      name                      =   "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type          =   "ebs" 
      irtualization-type        =   "hvm"
    }        
    most_recent                 = true
    owners                      = ["099720109477"]
  }
  ssh_username                  = "${ssh_user}"
}


build {
  sources     = [
    "source.amazon-ebs.standard"
  ]    
    
  provisioner "shell" {
    inline = [
      "echo Installing updates",
      "sleep 50",
      "sudo apt-get update --yes",
      "sudo apt-get install --yes apt-transport-https ca-certificates curl software-properties-common apt-transport-https git wget",
      "sudo apt-get update",
      "sudo apt dist-upgrade --yes"
    ]
  }

    #post-processor "shell-local" {
    #    inline = ["bash ./scripts/install_deocker.sh > ${build.name}.txt"]
    #}
   
  // fileset will list files in etc/scripts sorted in an alphanumerical way.
  scripts  = fileset("./", "docker/install_docker.sh")

  provisioner "shell" {
    nline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sleep 20",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
      "newgrp docker",
      "sudo chown \"$USER\":\"$USER\" /home/\"$USER\"/.docker -R",
      "sudo chmod g+rwx \"$HOME/.docker\" -R",
      "sudo chown \"$USER\":\"$USER\" /home/$USER/.docker -R",
      "sudo chmod g+rwx \"$HOME/.docker\" -R",
      "sudo systemctl enable docker.service",
      "sudo systemctl enable containerd.service",
      "sudo systemctl disable docker.service",
      "sudo systemctl disable containerd.service"
  ]
    }

    provisioner "file" {
      sources                     = fileset(path.cwd, "docker-compose.yaml")
      destination                 = local.jammy_destination
    } 

    provisioner "shell" {
      script                      = "${path.root}/docker-compose up"
      max_retries                 = local.jammy_max_retries
      pause_before                = "90s"
      jammy_start_retry_timeout   = local.jammy_start_retry_timeout

    #env = {
      ##        = local.jammy_attributes
    #}
  }

  post-processor "shell-local" {
    inline                      = ["docker-compose.yaml up -d build > ${build.name}.txt"]
  }

  provisioner "shell" {
  inline                      = ["TOKEN=$( curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\" && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s \"http://169.254.169.254/latest/meta-data/\"] >> result.txt"]
    }

  post-processor "shell-local" {
    inline                      = ["docker-compose.yaml up -d build > ${build.name}.txt"]
  }

  provisioner "shell" {
    only                        = ["amazon-ebs.standard"]
    inline = [
      "echo \"$( aws configure set region \"${var.region}\" --profile \"${var.profile}\" >> result.txt )\"",
      "CREDITTYPE=\"$( aws ec2 describe-instance-credit_
      "echo \"CPU Credit Specification is $CREDITTYPE\" >> result.txt",
      "[[ $CREDITTYPE == \"${var.standardCPUCredit}\" ]]"
    ]
  }

}


    

