# => CORP01_OS_10.100.63.0/24
# => vpc-06668cf85af082456
# => Profile


    #filters = {
    #        name                =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    #        root-device-type    =   "ebs" 
    #        virtualization-type =   "hvm"
    #}
    #most_recent     =   true
    #owners          =  "amazon"
    #imds_support    = "v2.0"
#}
packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "profile" {
    default     = "ingot"
}

variable "vpc_id" {
    default = "vpc-06668cf85af082456"
}
variable "subnet_id" {
    default    = "subnet-05bb983919aff8851"
}

#data "vpc_id" "vpc-06668cf85af082456" {}

#data "subnet_id" "defau1lt" {
#    vpc_id = data.aws_vpc.vpc_id
#}

variable "ami_id" {
    default = "ami-04dfd853d88e818e8"   
}

variable "region" {
    default = "eu-central-1" 
}

variable "amazon-ami" {
    default     =   "current"
}

variable "standardCPUCredit" {
    default     = "50"
}



#timestamp   = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"

    #communicator    = local.communicator.type
    #ssh_username    = local.communicator.username
    #ssh_password    = local.communicator.password
    #ssh_timeout     = local.communicator.timeout

source "amazon-ebs" "standard" {
        
    #ami_id                      = "ami-04dfd853d88e818e8"
    ami_name                    = "ubuntu-docker"
    instance_type               = "t3.xlarge"
    region                      = "${var.region}"
    ssh_username                = "ubuntu"
    ssh_agent_auth              = "false"
    enable_unlimited_credits    = "true"
    #temporary_key_pair_type     = ["awskey"]
    
    skip_create_ami             = "true"
    ssh_timeout                 = "30m"
    launch_block_device_mappings {
        device_name           = "/dev/sda1"
        volume_size           = "100"
        volume_type           = "gp3"
        delete_on_termination = "true"
        encrypted             = "false"
    }
    source_ami_filter {
        filters = {
            name                =   "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
            root-device-type    =   "ebs" 
            virtualization-type =   "hvm"
        }        
        most_recent     = true
        owners          =  ["099720109477"]
    }
        #ssh_username = "ubuntu"          
        #locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }
}


    #locals { creation_date = formatdate("YYYY-MM-DD-hhmm", timestamp()) }

build {
    sources     = [
        "source.amazon-ebs.standard"
        #"github.com/hashicorp/amazon"
    ]    
    provisioner "shell" {
        
        inline = [
            "echo Installing updates",
            "sleep 50",
            "sudo apt-get update -y",
            "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common apt-transport-https",
            "sudo apt-get update"
        ]
    }

    post-processor "shell-local" {
            inline = ["bash ./scripts/install_deocker.sh > ${build.name}.txt"]
    }
    


    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    }
 

        
        // fileset will list files in etc/scripts sorted in an alphanumerical way.
        #scripts           = fileset("./", "docker/install_docker.sh")
        
    #}
    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    }

    provisioner "shell" {
        inline = [
            "echo Installing Docker",
            "sleep 30",
            "sudo apt update",
            "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
            "sudo apt update",
            "sudo apt install -y docker-ce",
            "sudo usermod -aG docker ubuntu",
            "sudo apt clean && sudo apt purge",
            "sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/*",
            "curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-$(uname -s)-$(uname -m) | sudo tee -a /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            #"sudo bash ./usr/local/bin/docker-compose"
            "echo Done Installing Docker Compose version"
        ]
    }

    provisioner "shell" {
        inline = ["TOKEN=`curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\"` && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s http://169.254.169.254/latest/meta-data/"]
    }

    provisioner "shell" {
        only = ["amazon-ebs.standard"]
        inline = [
            "aws configure set region ${var.region} --profile ${var.profile}",
            "CREDITTYPE=$( aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
            "echo CPU Credit Specification is $CREDITTYPE"
            #"[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
        ]
    }

}


    

