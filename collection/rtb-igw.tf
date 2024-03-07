# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_route_table.rtb-07745c715a366341d:
resource "aws_route_table" "rtb-igw" {
  count            = var.acount
  propagating_vgws = []
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.rtb-igw[acount.index].id
      instance_id                = null
      ipv6_cidr_block            = null
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_peering_connection_id  = ""
      "local_gateway_id"         = ""
      "vpc_endpoint_id"          = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      core_network_arn           = ""
    },
  ]
  tags   = {}
  vpc_id = aws_vpc.main_vpc[acount.index].id
}
