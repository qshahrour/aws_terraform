# ==============#
# Providers => Provision file
# ===============
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ami" {
    ami_name      = var.ami_name
    instance_type = var.instance_type
    region        = var.region
    source_ami_filter {
        filters = {
            name                =   "ubuntu/images/*${var.ubuntu_version}-*"
            root-device-type    =   "ebs" 
            virtualization-type =   "hvm"
        }
        most_recent = true
        owners      = var.owners
    }
    ssh_username = var.ssh_username
}

build {
    sources = [
        "source.amazon-ebs.ubuntu"
    ]
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
        environment_vars  = [ "HOME_DIR=/home/ubuntu" ]
        execute_command   = "echo 'ubuntu' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
        expect_disconnect = true
        // fileset will list files in etc/scripts sorted in an alphanumerical way.
        scripts           = fileset("./", "docker/install_docker.sh")
    }
    post-processor "shell-local" {
        inline = ["docker-compose.yaml up -d build > ${build.name}.txt"]
    
    }
}
