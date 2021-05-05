resource "alicloud_vswitch" "ecs_vswitchs" {
  count        = length(var.ecs_cidrs)
  vpc_id       = var.vpc_id
  cidr_block   = element(var.ecs_cidrs, count.index)
  vswitch_name = "${var.names_prefix}${format("%03s", count.index + 1)}-${var.ecs_names_suffix}"
  zone_id      = element(var.ecs_zone_ids, count.index)
  tags         = var.tags
}

resource "alicloud_vswitch" "rds_vswitchs" {
  count        = length(var.rds_cidrs)
  vpc_id       = var.vpc_id
  cidr_block   = element(var.rds_cidrs, count.index)
  vswitch_name = "${var.names_prefix}${format("%03s", count.index + length(alicloud_vswitch.ecs_vswitchs) + 1)}-${var.rds_names_suffix}"
  zone_id      = element(var.rds_zone_ids, count.index)
  tags         = var.tags
}

resource "alicloud_vswitch" "kafka_vswitchs" {
  count        = length(var.kafka_cidrs)
  vpc_id       = var.vpc_id
  cidr_block   = element(var.kafka_cidrs, count.index)
  vswitch_name = "${var.names_prefix}${format("%03s", count.index + length(alicloud_vswitch.ecs_vswitchs) + length(alicloud_vswitch.rds_vswitchs) + 1)}-${var.kafka_names_suffix}"
  zone_id      = element(var.kafka_zone_ids, count.index)
  tags         = var.tags
}