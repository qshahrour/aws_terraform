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

#vpc_id = data.aws_vpc.vpc_id

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
  type        = string
  default     = "t3.xlarge"
}

variable "instance_ultimate" {
  type        = list(string)
  default     = ["r5dn.xlarge", "r5a.xlarge"]
}

variable "unlimitedCPUCredit" {
    default             = []
}

variable "standardCPUCredit" {
  default     = []
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

data "amazon-ami" "current" {
  filters = {
    name                  =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type      =   "ebs"
    virtualization-type   =   "hvm"
  }
  most_recent             =   true
  //imds_support            = "v2.0"
  owners                  = ["099720109477"]
}

data "http" "check" {
  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"
  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}


locals {
  //settings_file  = "${path.cwd}/settings.txt"
  root           = path.root
  timestamp      = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  settings_file  = "${path.cwd}/settings.txt"
  scripts_folder = "${path.root}/scripts"

}
  #root                              =   "${var.path.root}"
  //start_retry_timeout               =   "30m"
  #start_retry_timeout               =  "20s"
  //path                              =   "/home/ubuntu"
  //source_path                       =   "./docker-compose.yaml"
  //destination_path                  =   "/home/ubuntu/docker-compose.yaml"
  //HOME                              =   "/home/ubuntu"

locals { creation_date = formatdate("YYYY-MM-DD-hhmm", timestamp()) }

source "amazon-ebs" "standard" {

  ami_name                 = "${var.ami_prefix}-${local.timestamp}"
  instance_type            = "${var.instance_type}"
  region                   = "${var.region}"
  #ssh_timeout                     = "${var.local.communicator.timeout}"
  spot_price               = "auto"
  //spot_instance_types             = "${var.instance_type}"
  instance_types           = "${var.instance_type}"
  ssh_agent_auth           = false
  enable_unlimited_credits = true
  ssh_username             = "${var.ssh_user}"
  ssh_wait_timeout         = "10000s"
  ssh_timeout              = "30m"
  skip_create_ami          = true
  inline                   = [
    "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_username}",
    "chmod 0440 /etc/sudoers.d/99${var.ssh_username}"
  ]
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "100G"
    volume_type           ="gp3"
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
    //imds_support                = "v2.0"
  }

}

##########################################################################


source "amazon-ebs" "ultimate" {

  ami_name                 = "${var.ami_prefix}-${local.timestamp}"
  instance_type            = "${var.instance_ultimate}"
  region                   = "${var.region}"
  #ssh_timeout                     = "${var.local.communicator.timeout}"
  spot_price               = "auto"
  //spot_instance_types             = "${var.instance_type}"
  instance_types           = "${var.instance_type}"
  ssh_agent_auth           = false
  enable_unlimited_credits = true
  ssh_username             = "${var.ssh_user}"
  ssh_wait_timeout         = "10000s"
  ssh_timeout              = "30m"
  skip_create_ami          = true
  inline                   = [
    "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99${var.ssh_username}",
    "chmod 0440 /etc/sudoers.d/99${var.ssh_username}"
  ]
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "100G"
    volume_type           ="gp3"
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
    //imds_support                = "v2.0"
  }

}
#######################################################################################
#######################################################################################

build {
  sources     = [
    "source.amazon-ebs.standard",

    ]

  provisioner "shell" {
    environment_vars = [
      "EPO_URL          =https://download.docker.com/linux/${DIST_ID}",
      "ARCH              = $( dpkg --print-architecture )"
    ]
    inline = [
      "echo Installing updates",
      "sleep 3",
      "sudo apt-get update --yes",
      "sudo apt-get install --yes -qq apt-transport-https ca-certificates curl software-properties-common apt-transport-https git wget apt-utils net-tools mlocate",
      "sudo apt-get update -y",
      "sudo apt --yes -qq dist-upgrade"
    ]
    pause_before    = "10s"
    max_retries     = 5
    timeout         = "5m"
  }

  // fileset will list files in etc/scripts sorted in an alphanumerical way.
  //scripts  = fileset("./", "./script.sh")

  provisioner  "shell" {
    environment_vars = [
      "Home = "
    ]
  }

  post-processor "shell-local" {
    command    = ["docker-compose --version && docker --version"]
  }

  provisioner "shell" {
    inline    = ["sudo usermod -aG docker ubuntu"]
  }


  //provisioner "shell" {
  //  execute_command  = ["/bin/sh", "-c", "echo ${var.sudo_password}| {{.Vars}} {{.Script}}"]
  //}

  provisioner "file" {
    source              = fileset(path.cwd, "docker-compose.yaml")
    destination         = "/home/${var.ssh_user}/docker-compose.yaml"
  }

  post-processor "shell-local" {
    inline = ["docker-compose.yaml up -d > build.txt"]
  }


  provisioner "shell" {
    inline  = [
      ["curl http://169.254.169.254/latest/meta-data/ami-id >> result.txt"]
  }

  post-proccess "local-shell" {
    command = ["cat /home/ubuntu/result.txt"]

  }

  provisioner "shell" {
    only                = ["amazon-ebs.standard"]
    inline = [
      "aws configure set region ${var.region} --profile ${var.profile}",
      "CREDITTYPE=$( aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
      "echo CPU Credit Specification is $CREDITTYPE",
       "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
    ]
  }

}
