# ==================
#  Variables Fiel
# ==================

variable "region" {
    type                = string
    default             = "eu-central-1"
}

variable "profile" {
  type                  =   string
  default               =   "SysAdmin+Networking-637423636753"
}

variable "vpc_id" {
    description         = "The ID of the VPC"
    type                = string
    default             = null
}

variable "subnet_id" {
    description         = ""
    type                = string
    default             = ""
}

variable "aws_security_group" {
    description         = ""
    default             = "sg"
}

variable "sg" {
    description         = ""
    type                = string
    default             = "sg"
}

variable "owners" {
    type                = string
    default             = "637423636753"
}

variable "instance_type" {
    type                = string
    default             = "r5.xlarge" #"t3.xlarge"     
}

variable "ami_name" {
    type                =   string
    description         =   "The ID of the machine image (AMI) to use for the server."
    default             =   "ami-04dfd853d88e818e8"
}

###       error_message = "The image_id value must be a valid AMI ID, starting with \"ami-\"." 
variable "ami_id" {
    type                = string
    default             = "ami-04dfd853d88e818e8"
}

variable "unlimitedCPUCredit" {
    default             = []
}

variable "ubuntu_version" {
    type                = string
    default             = "ubuntu-focal-20.04-amd64-server"
}

variable "ssh_username" {
    type                = string
    default             = "ubuntu"
}

variable "ssh_key_name" {
    description         = "Key Pair."
    type                = string
    default             = "awskey"
    #default             = "~/.ssh/id_rsa"
}

