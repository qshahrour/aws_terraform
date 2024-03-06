

variable "region" {
    description =   "Default Region for the Default Profile"
    type        =   list(string)
    default     =   "eu-central-1" 
}
variable "container_instance" {
    description =   "value"
    default     =   ""
}   
variable "tags" {
    description =   "Tags"
    default     =   ""
}   
variable "Environment" {
    description =   "Targetted Env"
    type        =   string
    default     =   "dev"
}   
variable "profile" {
    description =   "value"
    default     =   "default"
}   
variable "" {
    description =   "value"
    default     =   ""
}   

variable "vpc_id" {
  description = "vpic id to create the cluster"
  type = string
}

#List of Private K8s subnets
variable "private_k8s_subnets" {
  description = "A list of Kubernetes subnets"
  type        = list(string)
}
