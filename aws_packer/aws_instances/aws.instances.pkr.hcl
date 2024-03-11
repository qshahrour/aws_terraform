#=======================================
# Sorce Template of Creatin AWS Instance
#=======================================

source "amazon-ebs" "standard" {

    ami_name              = "${var.ami_prefix}-${local.timestamp}"
    spot_price            = ["auto"]
    spot_instance_types   = ["t3.xlarge"]
    ebs_optimized         = true

    launch_block_device_mappings {
        device_name           = "/dev/sda1"
        volume_size           = "31"
        volume_type           = "gp3"
        delete_on_termination = true
    }

    source_ami_filter {
        filters = {
            // name             = "Windows_Server-2022-English-Full-Base-*"
            virtualization-type = "hvm"
            root-device-type    = "ebs"
        }

        owners          = ["amazon"]
        most_recent     = true
    }

    // user_data        = "<powershell>\r\n${file("${path.root}/boot/autounattend-first-logon.ps1")}\r\n</powershell>"
    tags = {
        "Name"          = local.ami_name
        "packer"        = "aws"
    }

    run_tags = {
        "Name"          = local.vm_name
       "packer"         = ""
    }

    spot_tags = {
        "Name"          = local.vm_name
        "packer"        = ""
    }

    communicator        = local.communicator.type
    ssh_username        = local.communicator.username
    ssh_password        = local.communicator.password
    ssh_timeout         = local.communicator.timeout
}
variable "cloud_base_filter_name" {
  type     = string
  default  = "cloud-hvm-2.0.*-x86_64-gp2"
}

variable "cloud_owners" {
  type     = string
  default  = "happycloud"
}

data "happycloud" "happycloud-linux2-east" {
  filters = {
    name =  var.cloud_base_filter_name
  }
  most_recent = true
  owners = var.cloud_owners
}

locals {
  cloud_owners           = ["happycloud"]
  cloud_base_filter_name = "cloud-hvm-2.0.*-x86_64-gp2"
}

data "happycloud" "happycloud-linux2-east" {
  filters = {
    name = local.cloud_base_filter_name
  }
  most_recent = true
  owners = local.cloud_owners

  locals {
  cloud_owners           = ["happycloud"]
  cloud_base_filter_name = "cloud-hvm-2.0.*-x86_64-gp2"
}

data "happycloud" "happycloud-linux2-east" {
  filters = {
    name = local.cloud_base_filter_name
  }
  most_recent = true
  owners = local.cloud_owners
}

}
