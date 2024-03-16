
#=> Defining Plugins
packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

###################################
## 	=> 	Defining Variables
###################################
variable "profile" {
  type      = string
  default   = "ingot"
}

variable "vpc_id" {
  type      = string
  default   = "current"
}
variable "subnet_id" {
  type      = string
  default   = "subnet-05bb983919aff8851"
}

variable "ami_id" {
  type      = string
  default   = "ami-04dfd853d88e818e8"
}

variable "region" {
  default   = "eu-central-1"
}

variable "amazon-ami" {
  default   = "current"
}

variable "instance_type" {
  default = "t3.xlarge"
}
variable "aws_region" {
  default   = "eu-central-1"
}

variable "unlimitedCPUCredit" {
  default   = []
}

variable "standardCPUCredit" {
  default   = []
}

variable "ssh_user" {
  type      = string
  default   = "ubuntu"
}

variable "app_name" {
  type      = string
  default   = "httpd"
}

variable "script_path" {
  default   = env("SCRIPT_PATH")
}

######################################

locals {
  app_name  = "httpd"
}

locals {
  ami_name    = "${var.app_name}-prodcution"
  timestamp   = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
}

########################################
# => Writing our Sources
source "amazon-ebs" "httpd" {
  ami_name            = "packer-${local.app_name}"
  instance_type       = "${var.instance_type}"
  region              = "${var.region}"
  source_ami          = "${var.ami_id}"
  ssh_username        = "${var.ssh_user}"
  spot_price          = "auto"
  ssh_wait_timeout    = "10000s"
  skip_create_ami     = true

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

###########################################

build {
  sources = ["source.amazon-ebs.httpd"]

  provisioner "shell" {
    inline = [
      "sudo apt update --yes",
      "sudo apt dist-upgrade --yes -qq"
    ]
    pause_before = "10s"
    max_retries = 5
    timeout = "5m"
  }

  provisioner "shell" {
    inline = [
      "sudo apt install --yes -qq apt-transport-https lsb-release ca-certificates software-properties-common curl git iputils-ping libicu-dev gnupg",
      "sudo apt autoclean"
      #"sudo rm -rf /var/lib/apt/lists/*",
      #"sudo rm -rf /var/log/*"
    ]
  }

  # "sudo apt-get install -q -y '${var.pkg}' jq"
  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu/gpg $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "apt-cache policy docker-ce",
      "sudo apt install -y docker-ce",
      "sudo systemctl status docker",
      "sudo rm /etc/apt/sources.list.d/docker.list",
      "sudo groupadd docker",
      "sudo usermod -aG docker ubuntu",
      "sudo apt-get clean",
      "sudo apt-get purge"
    ]
  }

  //post-proccess "local-shell" {
   // command = ["newgrp docker"]
  //}

  #post-proccess "local-shell" {
  #  command = ["Done installing"]
  #}

  provisioner "shell" {
    inline = [
      "sudo apt update --yes",
      "echo \"Done Installing Docker Compose version: 2\"",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.21.0//docker-compose-$(uname -s)-$(uname -m)\" | sudo tee /usr/local/bin/docker-compose",
      "sudo rm /usr/local/bin/docker-compose",
      "sudo apt-get install -y docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version"
      #"sudo rm -rf \"/var/lib/apt/lists/*\" \"/var/cache/apt/*\""
    ]
  }
}
  #provisioner "shell" {
    #only = ["amazon-ebs.unlimited"]
  #  inline = [
  #    "aws configure set region ${var.region} --profile ${var.profile}",\"CREDITTYPE=$( ${AWS_DEFAULT_REGION}=eu-central-2 aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID} | jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
  #    "echo CPU Credit Specification is ${CREDITTYPE}",
  #    "[[ $CREDITTYPE == ${var.unlimitedCPUCredit} ]]"
  #  ]
  #}

  ## This provisioner only runs for the 'first-example' source.
  #provisioner "shell" {
  #  only = ["amazon-ebs.httpd"]
  #  inline = [
  #    "aws configure set region ${var.region} --profile default",
  #    "CREDITTYPE=$(aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\")",
  #    "echo CPU Credit Specification is $CREDITTYPE",
  #    "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
  #  ]
  #}


#  # This provisioner only the second for the source.
#  provisioner "shell" {
#    environment_vars  = [ "HOME_DIR=/home/${var.ssh_user}" ]
#    execute_command   = "echo '${var.ssh_user}' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
#    expect_disconnect = true
#      // fileset will list files in etc/scripts sorted in an alphanumerical way.
#    scripts           = fileset(".", "zscripts/*.sh")
#  }
#
#  provisioner "shell" {
#    only = ["amazon-ebs.unlimited"]
#	  inline = ["TOKEN=\"$( curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\" )\" && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s http://169.254.169.254/latest/meta-data/"]
#	  script = "./${path.root}/010-update,sh"
#	  environment_vars = ["USER=${var.ssh_user}", "BUILDER=${upper(build.ID)}"]
#  }
#
#  provisioner "shell" {
#    only = ["amazon-ebs.standard"]
#    inline = [
#      "aws configure set region ${var.region} --profile ${var.profile}",
#      "CREDITTYPE=$( aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
#      "echo CPU Credit Specification is $CREDITTYPE",
#      "[[ $CREDITTYPE == ${var.standardCPUCredit} ]"
#    ]
#  }

#  provisioner "shell" {
#    environment_vars = #      EPO_URLq="https://download.docker.com/linux/${DIST_ID}",
#      ARCH="$( dpkg --print-architecture )"
#    ]
#    only = ["amazon-ebs.standard"]
#    inline = [
#      "echo Installing Docker",
#      "sleep 30",
#      "sudo apt-get update",
#      "echo ",
#      "echo \"[DEBUG] Installing engine dependencies from ${REPO_URL}\"",
#      "sudo update-ca-certificates -f",
#      "curl -fsSL \"${REPO_URL}/gpg\ | apt-key add -",
#      "echo \"deb [arch=\"${ARCH}\"] \"${REPO_URL}\" \"${DIST_VERSION}\" test\" > /etc/apt/sources.list.d/docker.list",
#      "sudo apt-get update"
#    ]
#    timeout = "5m"
#    max_retries = 5
#  }

#  provisioner "shell" {
#    only = ["amazon-ebs.unlimited"]
#    inline = [
#      "aws configure set region ${var.region} --profile ${var.profile}",
#      "CREDITTYPE=$( ${AWS_DEFAULT_REGION}=eu-central-2 aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID} | jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
#     "echo CPU Credit Specification is ${CREDITTYPE}",
#      "[[ $CREDITTYPE == ${var.unlimitedCPUCredit} ]]"
#    ]
#  }
#}

