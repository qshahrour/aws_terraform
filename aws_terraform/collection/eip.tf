resource "aws_eip" "my-eip" {
  count            = var.acount
  public_ipv4_pool = "amazon"
  tags             = {}
  domain            = "main_vpc"
  timeouts {}
}
