# Data Source File for building ec2 template





locals {
    creation_date = formatdate("YYYY-MM-DD-hhmm", timestamp())
}



source "amazon-ebs" "core" {    
    ami_name                = local.vm_name
    spot_price              = "auto"
    spot_instance_types     = var.instance_type
    instance_types          = var.instance_type
    ebs_optimized           = true

    launch_block_device_mappings {
        device_name           = "/dev/sda1"
        volume_size           = "100"
        volume_type           = "gp3"
        delete_on_termination = true
    }

    source_ami_filter {
         filters = {
        // name                = "Windows_Server-2022-English-Full-Base-*"
            virtualization-type = "hvm"
            root-device-type    = "ebs"
        }

        # owners = ["amazon"]
        most_recent = true
    }
}
    #tags = {
    #    "Name"   = local.vm_name
    #    "packer" = ""
    #}

    #run_tags = {
    #    "Name"   = local.vm_name
    #    "packer" = ""
    #}

    #spot_tags = {
    #    "Name"   = local.vm_name
    #    "packer" = ""
    #}
    #communicator = local.communicator.type
    #ssh_username = local.communicator.username
    #ssh_password = local.communicator.password
    #ssh_timeout  = local.communicator.timeout



data "amazon-ami" "ubuntu-jammy-amd64" {
    filters = {
        name                    =   "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
        root-device-type        =   "ebs"
        virtualization-type     =   "hvm"
    }

    most_recent     =   true
    owners          =   ["099720109477"]
    region          =   var.region

}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "standard" {
    region                  =   var.region
    source_ami              =   data.amazon-ami.standard.id
    instance_type           =   var.instance_type
    communicator            =   "ssh"
    ssh_username            =   var.ssh_username
    ssh_agent_auth          =   false
    temporary_key_pair_type =   "ed25519"
    ami_name                =   var.ami_name #"{{timestamp}}"
    skip_create_ami         =   true
    temporary_iam_instance_profile_policy_document {
        Version     =   "2012-10-17"
        Statement {
            [
                "Action"    =   ["*"]
                "Effect"    =   "Allow"
                "Resource"  =   ["*"]
            ]
        }     
    
    ]
}

source "amazon-ebs" "unlimited" {
    region                      =   var.region
    source_ami                  =   var.ami_name
    instance_type               =   var.instance_type
    ssh_username                =   var.ssh_username
    ssh_agent_auth              =   false
    enable_unlimited_credits    =   true
    temporary_key_pair_type     =   ""
    ami_name                    =   "%s"
    skip_create_ami             =   true
    metadata_options {
        http_endpoint                   =   "enabled"
        http_tokens                     =   "required"
        http_put_response_hop_limit     =   1
    }
    imds_support    =   "v2.0"
}
