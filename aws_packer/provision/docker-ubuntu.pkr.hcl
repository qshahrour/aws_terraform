packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "packer-linux-redis"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
