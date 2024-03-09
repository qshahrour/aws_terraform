# => CORP01_OS_10.100.63.0/24
# => vpc-06668cf85af082456




#
#communicator    = local.communicator.type
#ssh_username    = local.communicator.username
#ssh_password    = local.communicator.password
#ssh_timeout     = local.communicator.timeout           
source "amazon-ebs" "standard" {

    ami_name                        = "${var.ami_prefix}-${local.timestamp}"
    instance_type                   = "${var.instance_type}"
    region                          = "${var.region}"
    ssh_username                    = "${ssh_user}"
    ssh_agent_auth                  = "false"
    enable_unlimited_credits        = "true"
    #temporary_key_pair_type        = ["awskey"]  
    skip_create_ami                 = "true"
    ssh_timeout                     = "30m"
    launch_block_device_mappings {
        device_name                 = "/dev/sda1"
        volume_size                 = "100"
        volume_type                 = "gp3"
        delete_on_termination       = "true"
        encrypted                   = "false"
    }
    source_ami_filter {
        filters = {
            name                    =   "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
            root-device-type        =   "ebs" 
            virtualization-type     =   "hvm"
        }        
        most_recent        = true
        owners             = ["099720109477"]
    }      
}

build {
    sources     = [
        "source.amazon-ebs.standard"
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

    #post-processor "shell-local" {
    #    inline = ["bash ./scripts/install_deocker.sh > ${build.name}.txt"]
    #}

    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    }   
    // fileset will list files in etc/scripts sorted in an alphanumerical way.
    #scripts           = fileset("./", "docker/install_docker.sh")
    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    }

    provisioner "shell" {
        inline = [
            "echo \"Starting Install Docker\" > result.txt",
            "sleep 30",
            "sudo apt update",
            "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
            "curl -fsSL \"https://download.docker.com/linux/ubuntu/gpg\" | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=amd64] \"https://download.docker.com/linux/ubuntu\" focal stable'",
            "sudo apt update",
            "echo \"Installing Dcoker ce\" > result.txt"
            "sudo apt install -y docker-ce",
            "sudo usermod -aG docker ubuntu",
            "echo \"Removing Sources\" >> result.txt"
            "sudo apt clean && sudo apt purge",
            "sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/*",
            "curl -L \"https://github.com/docker/compose/releases/download/1.7.1/docker-compose-$(uname -s)-$(uname -m)\" | sudo tee -a /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            #"sudo bash ./usr/local/bin/docker-compose"
            "echo \"Done Installing Docker Compose version\" >> result.txt"
        ]
    }

    provisioner "shell" {
        inline = ["TOKEN=`curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\" && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s \"http://169.254.169.254/latest/meta-data/]" >> result.txt"]
    }

    provisioner "shell" {
        only = ["amazon-ebs.standard"]
        inline = [
            "echo \"aws configure set region ${var.region} --profile ${var.profile}\" >> result.txt",
            "CREDITTYPE=$( aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\" )",
            "echo \"CPU Credit Specification is $CREDITTYPE\" >> result.txt"
            "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
        ]
    }

}


    

