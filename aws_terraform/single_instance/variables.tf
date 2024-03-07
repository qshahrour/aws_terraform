

# AWS credentials profile stored in ~./aws/credentials
variable "profile" {
    description     =   "Main Profile"
    type            =   list(string)
    default         =   "default"   
}


variable "region" {
    description =   "Default Region for the Default Profile"
    type            =   list(string)
    default         =   "eu-central-1" 
}
variable "instance" {
    description     =   "value"
    default         =   ""
}   

variable "tags" {
    description     =   "Tags"
    default         =   ""
}

variable "Environment" {
    description     =   "Taged Env"
    type            =   string
    default         =   "dev"
}   
variable "profile" {
    description     =   "AWS User Profile"
    type            =   string
    default         =   "default"
}   
variable "region" {
    description     =   "AWS Region"
    type            =   string 
    default         =   "eu-central-1"
}   

variable "vpc_id" {
    description     =   "VPC ID"
    type            =   string
}

#List of Private K8s subnets
variable "private_k8s_subnets" {
    description     =   "A list of Kubernetes subnets"
    type            =   list(string)
}

variable "vpc_cidr" {
    description     =   "value"
    type            =   string
    default         =   ""
}   

variable "cidr" {
    description       =   "IPv4 CIDR Block for the VPC"
    type              =   string

}

variable "vpc_name" {
    description     =   "VPC Name for Frankfor Region"
    #default        =   "vpc-0d924ecc9c8e05b86"
    default         =   "vpc.frank.1" 
}   

variable "igw" {
    description   =     "value"
    type          =     string 
    default       =     []
}


variable "public_subnets_cidr" {
    description = "Public CIDR"
    type        = string
    default     = "value"
}


variable "public_subnets" {
    description   =   "Public Subnets"
    type          =   map(string)
    default       =   {}
}

variable "public_azs" {
    description     = "Public Availability Zone "
    type            = list(string)
}

variable "rtb" {
    description   =     "Default Route Table ID"
    type          =     string 
    default       =     "rtb-01bcf1c28f79555a9"
} 


variable "tags" {
    description   =   "A map of tags to add to all resources"
    type          =   map(string)
    default       =   {}
}

variable    "default_instance_os_tag" {

}

variable "instance_type" {
    type        =   string 
    default     =   "t3.xlarge"
}


variable "name_prefix" {
    
}


