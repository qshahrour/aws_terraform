############################
##  Variables Definetion  ##

variable "Environment" {
  type            = list(string)
  default         =   [ "dev" ]
}

variable "region" {
    description   = "Default Region for the Default Profile"
    type          = list(string)
    default       = "eu-central-1" 
}


# AWS credentials profile stored in ~./aws/credentials
variable "profile" {
    description   = "Main Profile per Account"
    type          = string 
    default       = "default"   
}

variable "subnet" {
    description   = "Zone b Subnet"
    default       = "subnet-06299b6361c2110af"
}

variable "key_name" {
    description   = "Zone a subnet"
    default       = ""
}  

variable "enable_nat_gateway" {
  description   = "NAT Gateway"
  type          = bool 
  default       = false
}

variable "enable_vpn_gateway" {
  description   = "VPN Gateway"
  type          = bool
  default       = false
}

variable "private_subnet_tags" {
  description     = "Additional tags for the public route tables"
  type            = map(string)
  default         = {}
}

variable "vpc_id" { 
  description       =   "vpic id to create the cluster"
  type              = string
}

variable "vpc_name" {
    description     = "Frankfor Region VPC Name"
    #default        = "vpc-0d924ecc9c8e05b86"
    type            = string
    default         = "vpc.frank.1" 
}   

variable "vpc_cidr" {
    description     = "value"
    type            = string
    default         = ""
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
  description = "value"
  default     = "igw-0cd5ec8d76546ffde"
} 

variable "instance_type" {
  default     = "t3.xlarge"
}

variable "rtb" {
    description =   "Default Route Table ID"
    default     =   "rtb-01bcf1c28f79555a9"
} 
variable "ec2_key_name" {
    description =   "Key Access"
    default     =   "~/.ssh/id_rsa"
} 
variable "associations" {
    description =   "value"
    default     =   ""
} 
variable "ec2_name" {
    description   = "EC2 Name"
    type          = map(string)
    default       = []
} 
variable "ec2_instance_count" {
    description   = "EC2 Instance Counts to create"
    default       = "1"
}   

variable "ec2_name" {
  description   = "A map of tags to add to all resources"
  type          = string
  default       = []
}

variable "public_subnets" {
  description   = "A list of public subnets inside the VPC"
  type          = list(string)
  default       = []
}


variable "default_tags" {
  description   = "Additional tags for the private Subnets"
  type          = map(string)
  default       = {}
}
#variable "data-sg" {
#    description =   "value"
#    default     =   ""
#}   

variable "security_group_id" {
  description   = "The ID of the security group to which we should add the Consul security group rules"
  type          = string
}
variable "allowed_inbound_cidr_blocks" {
  description   = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul"
  type          = list(string)
  default       = []
}
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "allowed_inbound_security_group_ids" {
  description   = "A list of security group IDs that will be allowed to connect to Consul"
  type          = list(string)
  default       = []
}

variable "allowed_inbound_security_group_count" {
  description   = "The number of entries in var.allowed_inbound_security_group_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only."
  type          = number
  default       = 0
}

variable "server_rpc_port" {
  description   = "The port used by servers to handle incoming requests from other agents."
  type          = number
  default       = 8300
}
variable "cli_rpc_port" {
  description   = "The port used by all agents to handle RPC from the CLI."
  type          = number
  default       = 8400
}

variable "serf_lan_port" {
  description   = "The port used to handle gossip in the LAN. Required by all agents."
  type          = number
  default       = 8301
}

variable "serf_wan_port" {
  description   = "The port used by servers to gossip over the WAN to other servers."
  type          = number
  default       = 8302
}

variable "http_api_port" {
  description   = "The port used by clients to talk to the HTTP API"
  type          = number
  default       = 8500
}

variable "https_api_port" {
  description   = "The port used by clients to talk to the HTTPS API. Only used if enable_https_port is set to true."
  type          = number
  default       = 8501
}

variable "dns_port" {
  description   = "The port used to resolve DNS queries."
  type          = number
  default       = 8600
}

variable "enable_https_port" {
  description   = "If set to true, allow access to the Consul HTTPS port defined via the https_api_port variable."
  type          = bool
  default       = false
}


variable  "private_subnets" {

  description   = "Private Subnet"
  type          = bool
  default       = false
}

variable "private_database_subnets" {
  description   = "Private Subnet"
  type          = bool
  default       = false
} 

variable "Environment" {
  type      = list(string)
}

locals {
  amazon_environments = {
      first_branch    =  "dev"
      second_branch   =   "production"
  }
}

locals {
  
}
