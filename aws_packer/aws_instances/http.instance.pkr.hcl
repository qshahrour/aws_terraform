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
  type            = string
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

variable "script_path" {
  default         = env("SCRIPT_PATH")
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
  #inline                   = [
  #  "echo '${var.ssh_user} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_user}",
  #  "chmod 0440 /etc/sudoers.d/99${var.ssh_user}"
  #]
  tags = {
    Env       = "demo",
    Name      = "packer-demo-${var.app_name}"
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 100
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

#######################################################################
# => Starting our build
########################################
build {
  sources = ["source.amazon-ebs.httpd"]

  provisioner "shell" {
    inline = [
        "sudo apt-get update",
        "sudo apt-get install --yes -qq ca-certificates curl lsb-release gnupg apt-utils software-properties-common wget git",
        "sudo add-apt-repository universe multiverse --yes",
        "sudo rm -rf /var/lib/apt/lists/*",
        "sudo rm -rf /var/log/*",
        "sudo apt autoclean -y"
    ]
  }

  post-processor "shell-local" {
    inline = ["sudo apt-get install --no-install-recommends -qq --yes nginx-full"]
  }
        #"sudo rm /var/lib/apt/lists/* && sudo apt-get clean"

  provisioner "shell" {

    inline = [
        q
      "sudo apt-get install --yes -qq apt-transport-https ca-certificates curl git",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL \"https://download.docker.com/linux/ubuntu/gpg\" -o /etc/apt/keyrings/docker.asc",
      "sudo a+r q/etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc]\" \"https://download.docker.com/linux/ubuntu\" \"$(. /etc/os-release && echo jammy)\" stable | sudo tee \"/etc/apt/sources.list.d/docker.list\" > \"/dev/null\" \",
      "\"$(. /etc/os-release && echo \"${VERSION_CODENAME}\") stable\" | sudo tee \"/etc/apt/sources.list.d/docker.list\" > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update --yes",
      "sudo apt-get install -y docker-ce-cli docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo rm -rf /var/lib/apt/lists/* /var/log/*"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "sudo groupadd docker",
      "sudo usermod -a -G docker ubuntu"
    ]
  }

  provisioner "shell" {
    inline = [ "echo | nc -G 5 -w 5 -v localhost 10022 2>&1" ]
  }

  provisioner "shell" {
    inline = [ "curl -kvs --connect-to \"ifconfig.co:443:localhost:8443\" \"https://ifconfig.co\"/" ]
  }
  // provisioner "shell" {
  //    inline   = ["script = script/install_docker.sh"]
  //}

  post-processor "shell-local" {
    inline = ["script has been copied to server"]
  }

  provisioner "file" {
    source = "./docker-compose.yaml"
    destination = "/home/ubuntu/"

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
