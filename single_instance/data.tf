

data "aws_route_table" "rtb-10-1" {
  #subnet_id=data.aws_subnet.c9subnet.id
  #filter {
  #  values = [ data.aws_subnet.c9subnet.id ]
  ##  name = "association.subnet-id"
  #}
  #route_table_id = var.rtb_id_10_1
}

resource "aws_route" "route-10-0" {
  route_table_id         = data.aws_route_table.defrt.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = data.aws_ec2_transit_gateway.mytgw.id
}

resource "aws_route" "route-172-31" {
  route_table_id         = data.aws_route_table.rtb-10-1.id
  destination_cidr_block = "172.31.0.0/16"
  transit_gateway_id     = data.aws_ec2_transit_gateway.mytgw.id
}


#data "aws_security_group" "sg_10_1" {
 # id = var.sg_id_10_1
##}

#data "aws_security_group" "defsg" {
 # id = var.sg#_id
#}

data "aws_subnet" "inst-10-1-subnet" {
  id     = data.aws_instance.instance-10-1.subnet_id
  vpc_id = data.aws_vpc.vpc-10-1.id
}

data "aws_subnet" "c9subnet" {
  id     = data.aws_instance.c9.subnet_id
  vpc_id = data.aws_vpc.dvpc.id
}
data "aws_instance" "instance-10-1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc-10-1.id]
  }
}

data "aws_instance" "c9" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dvpc.id]
  }
}


data "aws_ec2_transit_gateway" "mytgw" {
  filter {
    name   = "options.amazon-side-asn"
    values = ["64512"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
