# Variables

variable "region" {
    type    = string
    default = "eu-central-1"
}

variable "instance_type" {
    type    = list(string)
    default = [
        "t2.medium"
        "t3.xlarge"
    ]
}

variable "ami_name" {
    type        =   string
    description =   "The ID of the machine image (AMI) to use for the server."
    default     =   "t3.xlarge"
}


variable "ubuntu_version" {
    default = "ubuntu-focal-20.04-amd64"
}

variable "image_id" {
    type    = string
    default = "packer-linux-aws"
    validation {
        condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
        error_message = "The image_id value must be a valid AMI ID, starting with \"ami-\"."    
    }
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}


locals {
  files = {
    install.sh = {
      destination = "$HOME"
    }
    bar = {
      destination = "baar"
    }
  }
}
