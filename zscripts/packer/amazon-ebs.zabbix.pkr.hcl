#=> Defining Plugins
packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
######################################
###################################
## 	=> 	Defining Variables
###################################
variable "profile" {
  type      = string
  default   = "ingot"
}

//variable "vpc_id" {
//  description   ="The VPC you're building AMI's in"
//  type          =string
//  default       ="vpc-0d924ecc9c8e05b86"
//}
variable "vpc_id" {
  type      = string
  default   = "current"
}

variable "region" {
  description   ="The AWS region you're using"
  type          =string
  default       = "eu-central-1"
}

variable "subnet_id" {
  description   ="The Subnet to build the AMI inm that's ssh'able"
  type          =string
  default   = "current"
  //default       ="subnet-05f8f3c120238ca8d"
}

variable "ami_id" {
  type      = string
  default   = "ami-04dfd853d88e818e8"
}

variable "BUILD_NUMBER" {
  description="The build number"
  type          =string
  default       ="1"
}

variable "instance_type" {
  default       ="t3.large"
  description   ="The AMI build instance"
  type          =string
}

variable "ami_users" {
  default=[]
}

variable "associate_public_ip_address" {
  type          =bool
  default       =true
}

variable "ssh_interface" {
  type          = string
  default       = "public_ip"
}

variable "app_name" {
  type      = string
  default   = "Zabbix"
}

variable "ami_prefix" {
  type      = string
  default   = "ubuntu base 22.04"
}

variable "source_path" {
  type      = string
  default   = "./"
}

variable "amazon-ami" {
  default   = "current"
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
+
variable "unlimitedCPUCredit" {
  type  = string
}

variable "script_path" {
  default   = env("SCRIPT_PATH")
}
#locals {
#  image_options         = var.images[var.image]
#  image_name            = "${basename(path.cwd)}/${var.image}"
#  image_description     = local.image_options.core.image_description
#  image_version         = "${local.image_options.core.image_version}.${var.version}"
#  image_provider        = var.provider
#  image_build           = var.build
#  artifacts_directory   = "${path.cwd}/../../artifacts/${local.image_name}/${local.image_provider}/${var.build}"
#}

locals {
  app_name            = "Zabbix"
  root                = path.root
  scripts_folder      = "${path.root}/scripts"
  settings_file       = "${path.cwd}/settings.txt"
  ami_name            = "${var.app_name}-prodcution"
  timestamp           = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  creation_date       = "${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
}

########################################
# => Writing our Sources
source "amazon-ebs" "Zabbix" {
  name                = "packer-build"
  output              = "AWS AMI"
  ami_description     = "amazon ubuntu AMI"
  ami_name            = "${var.ami_prefix}-${local.timestamp}"
  instance_type       = "${var.instance_type}"
  region              = "${var.region}"
  source_ami          = "${var.ami_id}"
  #spot_instance_types       = ["t3.xlarge"]
  #enable_unlimited_credits  = true
  ssh_username              = "${var.ssh_user}"
  ssh_agent_auth            = false
  ssh_timeout               = "30m"
  ssh_wait_timeout          = "10000s"

  ebs_optimized             = true
  #skip_create_ami           = true
  associate_public_ip_address     = var.associate_public_ip_address

  tags = {
    Name          = "ubuntu-base-packer"
  }

  spot_price                  = "auto"
  ssh_interface               = var.ssh_interface
  //subnet_id                   = var.subnet_id
  temporary_key_pair_name     = "amazon-packer-{{timestamp}}"
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false
  }
  source_ami_filter {
    filters = {
      name                  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type      = "ebs"
      virtualization-type   = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}
###########################################

build {

sources=["source.amazon-ebs.Zabbix"]

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
      "sudo apt-get update -y",
      "sudo apt install --yes -qq apt-transport-https lsb-release ca-certificates software-properties-common curl wget apt-utils git iputils-ping libicu-dev gnupg",
      "sudo apt autoclean",
      "sudo apt-get update -y",
    ]
    pause_before = "10s"
    max_retries = 5
    timeout = "5m"
  }

  provisioner "shell" {
    inline = ["echo \"Runnning Docker Installation Script\""]
  }

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/ubuntu"
    ]
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true
    script = "./scripts/install-docker.sh"
  }

  post-processor "shell-local" {
    inline = ["echo Hello World from ${source.type}.${source.name}"]
  }

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/ubuntu"
    ]
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true
    script = "./scripts/install-compose.sh"
  }

  provisioner "shell" {
    only = ["amazon-ebs.unlimited"]
    inline = [
      "aws configure set region ${var.region} --profile ${var.profile}",\"CREDITTYPE=$( ${AWS_DEFAULT_REGION}=eu-central-2 aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID} | jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
      "echo CPU Credit Specification is ${CREDITTYPE}", "[[ $CREDITTYPE == ${var.unlimitedCPUCredit} ]]"
    ]
  }

}
  // provisioner "shell" {
  // inline = [
  //    "echo '${var.ssh_user} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_user}",
  //    "chmod 0440 /etc/sudoers.d/99${var.ssh_user}"
  //  ]
  //}
  // command = ["echo \"Successfully installed Docker Engine"]
  // "sudo apt-get install -q -y '${var.pkg}' jq"
  // post-proccess "local-shell" {
  //  command = ["Done installing"]
  //}

  //provisioner "shell" {
  //  inline = [
  //    "sudo apt update --yes",
  //    "echo \"Done Installing Docker Compose version: 2\"",
  //    "sudo curl -L \"https://github.com/docker/compose/releases/download/1.21.0//docker-compose-$(uname -s)-$(uname -m)\" | sudo tee /usr/local/bin/docker-compose",
  //    "sudo rm /usr/local/bin/docker-compose",
  //    "sudo apt-get install -y docker-compose",
  //    "sudo chmod +x /usr/local/bin/docker-compose",
  //    "docker-compose --version"
  //    #"sudo rm -rf \"/var/lib/apt/lists/*\" \"/var/cache/apt/*\""
  //  ]
  //}



  ## This provisioner only runs for the 'first-example' source.
  // provisioner "shell" {
  //  only = ["amazon-ebs.httpd"]
  //  inline = [
  //      "aws configure set region ${var.region} --profile default",
  //      "CREDITTYPE=$(aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\")",
  //      "echo CPU Credit Specification is $CREDITTYPE",
  //      "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
  //  ]
  //}


#  # This provisioner only the second for the source.
#  provisioner "shell" {
#    environment_vars  = [ "HOME_DIR=/home/${var.ssh_user}" ]
#    execute_command   = "echo '${var.ssh_user}' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
#    expect_disconnect = true
#      // fileset will list files in etc/scripts sorted in an alphanumerical way.
#    scripts           = fileset(".", "zscripts/*.sh")
#  }   environment_vars = #      EPO_URLq="https://download.docker.com/linux/${DIST_ID}",
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
