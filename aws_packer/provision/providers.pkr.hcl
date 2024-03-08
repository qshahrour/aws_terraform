# ==============================
# Providers => Provision filew
# ==============================
#default     =   aws_vpc.default.id          
#vpc_id      =   aws_eip.aws_instance      
#region      =     

#provider "aws" {   
#    source                          = source.amazon-ebs.zabbix
#    region                          = `var.region
#    profile                         = var.profile
#}
#    default     = var.vpc_id == null ? true : false
    id          = var.vpc_id
#}

#data "subnet_id" "defau1lt" {
#    vpc_id = data.aws_vpc.vpc_name.id
#}

#data "region" "default" {}
#data "profile" "ingot" {
#    profile     =   "SysAdmin+Networking-637423636753"
#}

data "amazon-ami" "current" {
    filters = {
            name                =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
            root-device-type    =   "ebs" 
            virtualization-type =   "hvm"
    }
    most_recent     =   true
    owners        =  "637423636753"
    imds_support    = "v2.0"
}

build {
    sources = [
        "source.amazon-ebs.zabbix"
    ]

    source "amazon-ebs" "zabbix" {
        ami_name                    = var.ami_name
        instance_type               = var.instance_type
        region                      = var.region
        ssh_username                = var.ssh_username
        ssh_agent_auth              = false
        enable_unlimited_credits    = true
        temporary_key_pair_type     = ["~/.ssh/id_rsa"]
        # ami_name                  = "%s"
        skip_create_ami             = true
        launch_block_device_mappings {
            device_name           = "/dev/sda1"
            volume_size           = "100"
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = false
        }

        #owners  =  637423636753

        source_ami_filter {
            filters = {
                name                =   "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
                root-device-type    =   "ebs" 
                virtualization-type =   "hvm"
            }        
            owners  =  "amazon"
        }   
        #temporary_iam_instance_profile_policy_document {
            #Version = "2012-10-17"
            #Statement { 
            #    [
            #        "Action"    =   ["*"]
            #        "Effect"    =   "Allow"
            #        "Resource"  =   ["*"]
            #   ]
            #}
        # }
    }

    locals { creation_date = formatdate("YYYY-MM-DD-hhmm", timestamp()) }
    locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

    provisioner "shell" {
        inline = [
            "echo Installing Docker",
            "sleep 30",
            "sudo apt-get update",
            "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
            "sudo apt-get update",
            "sudo apt-get install -y docker-ce",
            "sudo usermod -aG docker ubuntu",
        ]
    }

    provisioner "shell" {
        only = ["amazon-ebs.standard"]
        inline = [
            "aws configure set region ${var.region} --profile ${var.profile}",
            "CREDITTYPE=$( aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
            "echo CPU Credit Specification is $CREDITTYPE",
            "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
        ]
    }

    provisioner "shell" {
        inline = ["TOKEN=`curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\"` && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s http://169.254.169.254/latest/meta-data/"]
    }

    provisioner "shell" {
        environment_vars  = [ "HOME_DIR=/home/ubuntu" ]
        execute_command   = "echo 'ubuntu' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
        
        // fileset will list files in etc/scripts sorted in an alphanumerical way.
        scripts           = fileset("./", "docker/install_docker.sh")
        expect_disconnect = true
    }
    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    }
}

