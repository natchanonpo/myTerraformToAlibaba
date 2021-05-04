resource "alicloud_vpc" "vpc" {
  resource_group_id = var.resource_group_id
  vpc_name          = var.name
  cidr_block        = var.cidr
  tags              = var.tags
}