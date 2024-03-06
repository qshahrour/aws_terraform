########################
##  Variables Definetion

variable "region" {
    description =   "Default Region for the Default Profile"
    default     =   "eu-central-1" 
}

# AWS credentials profile stored in ~./aws/credentials
variable "main-profile" {
    description =   "Main Profile per Account"
    default     =   "default"   
}


variable "zoneb_subnet" {
    description =   "Zone b Subnet"
    default     =   "subnet-06299b6361c2110af"
}

variable "zonea_subnet" {
    description =   "Zone a subnet"
    default     =   ""
}  

variable "private_subnet_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "vpic id to create the cluster"
  type = string
}

variable "vpc_name" {
    description     =   "Frankfor Region VPC Name"
    #default        =   "vpc-0d924ecc9c8e05b86"
    default         =   "vpc.frank.1" 
}   

variable "vpc_cidr" {
    description     =   "value"
    type            = string
    default         =   ""
}   

variable "cidr" {
  description       = "The IPv4 CIDR block for the VPC"
  type              = string

}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "igw" {
    description =   "value"
    default     =   "igw-0cd5ec8d76546ffde"
} 


variable "rtb" {
    description =   "Default Route Table ID"
    default     =   "rtb-01bcf1c28f79555a9"
} 
variable "" {
    description =   "value"
    default     =   ""
} 
variable "sub1_ass" {
    description =   "value"
    default     =   ""
} 
variable "sub2_ass" {
    description =   "value"
    default     =   ""
} 
variable "sub3_ass" {
    description =   "value"
    default     =   ""
}   

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}


#variable "data-sg" {
#    description =   "value"
#    default     =   ""
#}   






