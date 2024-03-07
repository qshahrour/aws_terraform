vpc_name            = "VPC"
vpc_cidr            = "172.18.0.0/16"
vpc_dmz_cidr        = "172.19.0.0/16"
cidr                = "10.103.0.0/16"
##   vpc name    ##
##   vpc cidr   ##
ec2_key_name        = "Frankfurt_key.pem"
azs                 = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] #vpc availability zones
private_subnets     = ["10.103.10.0/24", "10.103.11.0/24", "10.103.12.0/24"]
public_subnets      = ["10.103.20.0/24", "10.103.21.0/24", "10.103.22.0/24"]

#public_subnets.id      = "subnet-06299b6361c2110af"
Environment         =   ["dev", "prod", "devops"]


# public_subnenable_https_port    = false


# Global
# ----------------------------
#provider_default_tags = {
##    Environment = "sta  ging"
#}

# Networking
# ----------------------------


    #Subnets
    #description         = "Allow port 22"
    #from_port           = 22
    #to_port                     = 22
    #protocol    = "tcp"
    #                                            ``````````````````````````````                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           cidr_blocks = ["10.0.1.0/24", "190.86.109.131/32"]
    #}, {
    #    description = "Allow port HTTP"
    #    from_port   = 80
    #    to_port     = 80
    #    protocol    = "tcp"
    #    cidr_blocks = ["0.0.0.0/0"]
#
    # }, {
    # description = "Allow ICMP"
    #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        from_port   = -1
    #to_port     = -1
    #protocol    = "icmp"
    #cidr_blocks = ["10.0.1.0/24", "190.86.109.131/32"]
#}]

#sg01_tags = {
  #Name = "sg01-tf-allow-ssh-http"
 # Info = "Allow SSH & HTTP"
#}


#sn_name_prefix = "sn-public-tf-"
