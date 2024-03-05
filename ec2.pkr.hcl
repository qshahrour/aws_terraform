# Source File for building ec2 template


data "amazon-ami" "ubuntu-jammy-amd64" {
    filters = {
        name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
        root-device-type    = "ebs"
        virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["099720109477"]
    region      = var.region

}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "standard" {
    region                  = var.region
    source_ami              = data.amazon-ami.standard.id
    instance_type           = var.instance_type
    communicator            = "ssh"
    ssh_username            = var.ssh_username
    ssh_agent_auth          = false
    temporary_key_pair_type = "ed25519"
    ami_name                = var.ami_name #"{{timestamp}}"
    skip_create_ami         = true
    temporary_iam_instance_profile_policy_document {
        Version = "2012-10-17"
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
    region                   = var.region
    source_ami               = "ami-044065b5480679567"
    instance_type            = "t2.medium"
    ssh_username             = var.ssh_username
    ssh_agent_auth           = false
    enable_unlimited_credits = true
    temporary_key_pair_type  = "ed25519"
    ami_name                  = "%s"
    skip_create_ami          = true
    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
    }
    imds_support = "v2.0"

}
