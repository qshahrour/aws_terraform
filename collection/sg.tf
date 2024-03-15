resource "aws_security_group" "sg" {
  count       = var.acount
  description = "SG-inbound"
  vpc_id      = aws_vpc.main_vpc[acount.index].id
}
