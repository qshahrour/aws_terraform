## Packer Module: ##

## Basic examples of usage: ##

data "amazon-parameterstore" "basic" {
  name              = "packer_test"
  with_decryption   = false
}

## usage example of the data source output ##
locals {
  value     = data.amazon-parameterstore.basic.value
  version   = data.amazon-parameterstore.basic.version
  arn       = data.amazon-parameterstore.basic.arn
}

## Basic example of an Amazon data source authentication using assume_role:

data "amazon-parameterstore" "basic" {
  name              = "packer_basic"
  with_decryption   = false

  assume_role {
    role_arn        = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
    session_name    = "SESSION_NAME"
    external_id     = "EXTERNAL_ID"
  }
}

data "amazon-ami" "basic" {
  filters = {
    virtualization-type   = "hvm"
    name                  = "ubuntu/images/*ubuntu-jammyl-22.04-amd64-server-*"
    root-device-type      = "ebs"
  }
  owners          = ["099720109477"]
  most_recent     = true
}

## Two Providioners ##
1- aws
2- shell

    
