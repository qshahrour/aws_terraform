# ==================
#  Variables Fiel
# ==================

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
    default     =   "ami-04dfd853d88e818e8"
}

#ariable "ami" {
#    type        =   string
#    description =   "machine image (AMI)."
#    default     =   []
#}

variable "owners " {
    type    = string
    default = "637423636753"
}


variable "ubuntu_version" {
    type    = string
    default = "ubuntu-focal-20.04-amd64-server"
}

variable "ami" {
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



variable "aws_profile" {
  type      =   string
  default   =   "SysAdmin+Networking-637423636753"
}


