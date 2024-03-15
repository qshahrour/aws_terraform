resource "aws_subnet" "private_subnet" {
  count                           = var.acount
  assign_ipv6_address_on_creation = false
  availability_zone               = data.aws_availability_zones.az.names[0]
  cidr_block                      = format("10.%s.4.0/24", acount.index + 1)
  map_public_ip_on_launch         = false
  tags = {
    "Name" = format("Priv subnet 10-%s-4-0", acount.index + 1)
  }
  vpc_id = aws_vpc.main_vpc[acount.index].id

  timeouts {}
}

resource "aws_subnet" "public_subnets" {
  count                           = var.acount
  assign_ipv6_address_on_creation = false
  availability_zone               = data.aws_availability_zones.az.names[0]
  cidr_block                      = format("10.%s.1.0/24", acount.index + 1)
  map_public_ip_on_launch         = false
  tags = {
    "Name" = format("Pub subnet 10-%s-1-0", acount.index + 1)
  }
  vpc_id = aws_vpc.main_vpc[acount.index].id

  timeouts {}
}
