###################################
## 	=> 	Defining Variables
###################################
variable "profile" {
  type      = string
  default   = "ingot"
}

variable "vpc_id" {
  description   ="The VPC you're building AMI's in"
  type          =string
  default       ="vpc-0d924ecc9c8e05b86"
}

variable "region" {
  description   ="The AWS region you're using"
  type          =string
  default       = "eu-central-1"
}

variable "subnet_id" {
  description   ="The Subnet to build the AMI inm that's ssh'able"
  type          =string
  default       ="subnet-05f8f3c120238ca8d"
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

variable "vpc_id" {
  type      = string
  default   = "current"
}
//variable "subnet_id" {
//  type      = string
//  default   = "subnet-05bb983919aff8851"
//}

variable "script_path" {
  default   = env("SCRIPT_PATH")
}
