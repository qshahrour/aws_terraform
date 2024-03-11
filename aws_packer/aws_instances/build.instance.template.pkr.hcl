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
  type        = string
  default     = "current"
}
variable "subnet_id" {
  default     = "subnet-05bb983919aff8851"
}

#variable "subnet_id" {
  #vpc_id = data.aws_vpc.vpc_id
#}
variable "ami_id" {
  type        = string
  default     = "ami-04dfd853d88e818e8"   
}

variable "region" {
  default     = "eu-central-1" 
}

variable "amazon-ami" {
  default     = "current"
}

variable "instance_type" {
  default     = "t3.xlarge"
}

variable "standardCPUCredit" {
  default     = "50"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
}

variable "source_path" {
  type      = string
  default   = "./"
}

variable "ami_prefix" {
  type      = string
  default   = "packer-linux"
}

variable "script_path" {
  default = env("SCRIPT_PATH")
}



locals {
  script_path                       = "./script.sh"
  timestamp                         = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  settings_file                     = "${path.cwd}/settings.txt"
  scripts_folder                    = "${path.root}/scripts"
  root                              =   path.root
  start_retry_timeout               =   "30m"
  ssh_user                          =   "ubuntu"
  #start_retry_timeout               =  "20s"
  path                              =   "/home/ubuntu"
  source_path                       =   "./docker-compose.yaml"
  destination_path                  =   "/home/ubuntu/docker-compose.yaml"
  HOME                              = "/home/ubuntu"
}


source "amazon-ebs" "standard" {

  ami_name                        = "${var.ami_prefix}-${local.timestamp}"
  #ami_name                        = "${var.ami_id}"
  instance_type                   = "${var.instance_type}"
  region                          = "${var.region}"
  #ssh_timeout                     = "${var.local.communicator.timeout}"
  ssh_agent_auth                  = false
  enable_unlimited_credits        = true
  #temporary_key_pair_type        = ["awskey"] 
  ssh_username                    = "ubuntu"
  ssh_wait_timeout                = "10000s"
  skip_create_ami                 = true
  ssh_timeout                     = "30m"
  # skip_create_ami                 = true
  #inline                         = ["echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_username}", "chmod 0440 /etc/sudoers.d/99${var.ssh_username}"]
  launch_block_device_mappings {
    device_name                 = "/dev/sda1"
    volume_size                 = "100"
    volume_type                 = "gp3"
    delete_on_termination       = true
    encrypted                   = false
  }
  source_ami_filter {
    filters = {
      name                    = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type          = "ebs" 
      virtualization-type        = "hvm"
  } 

           
    most_recent                 = true
    owners                      = ["099720109477"]
  }
  
}

source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
}


#provisioners = {
#  type            = "shell",
#  scripts         = "./docker-compose.yaml",
#  destination     = "/home/ubuntu"
#  pause_before    = "4s"
#}


build {
  #name    = "packer-docker-build"
  sources     = [
    "source.amazon-ebs.standard"
  ]    

  provisioner "shell" {
    inline = [
      "echo Installing updates",
      "sleep 50",
      "sudo apt-get update --yes",
      "sudo apt-get install --yes -qq apt-transport-https ca-certificates curl software-properties-common apt-transport-https git wget",
      "sudo apt-get update -y",
      "sudo apt --yes -qq dist-upgrade"
    ]
  }

  // fileset will list files in etc/scripts sorted in an alphanumerical way.
  //scripts  = fileset("./", "./script.sh")
  provisioner "shell" {

    inline = [
      #"sudo curl -fsSL https://get.docker.com -o get-docker.sh",
      #"sudo sh get-docker.sh",
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl",
      "sleep 20",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL \"https://download.docker.com/linux/ubuntu/gpg\" -o \"/etc/apt/keyrings/docker.asc\"",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc]\" \"https://download.docker.com/linux/ubuntu\" \"$(. /etc/os-release && echo jammy)\" stable | sudo tee \"/etc/apt/sources.list.d/docker.list\" > \"/dev/null\"",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      #"sudo mkdir -pv /home/ubuntu/.docker",
      #"sudo chown ubuntu:ubuntu /home/ubuntu/.docker -R",
      #"sudo chmod g+rwx /home/ubuntu/.docker -R",
      "sudo systemctl enable docker.service",
      "sudo systemctl enable containerd.service",
      "sudo systemctl start docker.service",
      "sudo systemctl start containerd.service"
    ]
  }

  post-processor "shell-local" {
    inline    = [
      "sudo usermod -aG docker ubuntu",
      "newgrp docker"
    ]
  }

  provisioner "shell" {
    inline = [
      "curl -L \"https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)\" > |sudo tee /usr/local/bin/docker-compose",
      "sudo apt-get install -y docker-compose",
      #"sudo chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version"
    ]
  }

  #provisioner "shell"  {
  #  execute_command = "echo 'vagrant'|sudo -S -E bash '{{.Path}}'",
  #  scripts = ["./script.sh"]
  #}

  #provisioner "file" {
  #    source        = "../scripts/install_docker.sh",
  #    destination   = "/tmp"
 # }

  #provisioner "shell" {
  #  execute_command = "echo 'ubuntu' |sudo -S -E bash '{{.sh}}'"
  #}

  #post-processors "local-shell" {
  #  output       = result.txt
  #  strip_path   = true
  #}


  provisioner "file" {
    sources          = fileset(path.cwd, "docker-compose.yaml") 
    #destination       = local.destination_path
    destination       = "/tmp"
  }

  post-processor "shell-local" {
    inline            = ["docker-compose up -d > result.txt"]
  }
  
  post-processor "shell-local" {
    inline            = ["echo provisioner file"]
  }

  post-processor "manifest" {
    output      = "result.txt"
    strip_path  = true
  }
  
  provisioner "shell" {
    inline      = ["TOKEN=$( curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\" && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s \"http://169.254.169.254/latest/meta-data/\"] >> result.txt"]

  }

  #provisioner "shell" {
    #only                        = ["amazon-ebs.standard"]
    #inline = [
    #  "echo \"$( aws configure set region \"${var.region}\" --profile \"${var.profile}\" >> result.txt )\"",
      #"CREDITTYPE=\"$( aws ec2 describe-instance-credit_7]

    #  #"echo \"CPU Credit Specification is $CREDITTYPE\" >> result.txt",
    #  3"[[ $CREDITTYPE == \"${var.standardCPUCredit}\" ]]"
    #]
  #}

}


    

