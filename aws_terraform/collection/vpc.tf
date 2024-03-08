

resource "aws_vpc" "main_vpc" {
  count                            = var.acount
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = lookup(var.aws_cidr, var.aws_vpc[acount.index])
  enable_dns_hostnames             = false
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    "Name" = var.aws_vpc[acount.index]
  }
}
