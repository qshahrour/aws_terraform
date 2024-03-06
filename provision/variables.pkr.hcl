# ==================
#  Variables Fiel
# ==================

variable "region" {
    type    = string
    default = "eu-central-1"
}

variable "instance_type" {
    type    = string
    default = "r5.xlarge"
        #"t3.xlarge"
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

#variable "owners " {
##   #type    = string
#    default = "637423636753"
#}

variable "unlimitedCPUCredit" {

}

variable "ubuntu_version" {
    type    = string
    default = "ubuntu-focal-20.04-amd64-server"
}

#variable "ami" {
#    type    = string
#    default = "ami-04dfd853d88e818e8"
###       error_message = "The image_id value must be a valid AMI ID, starting with \"ami-\"."    
 #   }
#}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}



variable "aws_profile" {
  type      =   string
  default   =   "SysAdmin+Networking-637423636753"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  type        = string
  default     = null
}
