resource "alicloud_resource_manager_resource_group" "resource_group" {
  resource_group_name = var.name
  display_name        = var.name
}