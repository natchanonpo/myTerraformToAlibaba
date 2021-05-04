resource "alicloud_log_project" "log" {
  name        = lower(var.log_name)
  description = "log for k8s"
  tags        = local.tags
}

locals {
  full_cluster_addons = concat(var.cluster_addons, {
    "name"   = "logtail-ds",
    "config" = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":\"${alicloud_log_project.log.name}\"}"
  })
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  name                         = var.k8s_name
  resource_group_id            = var.resource_group_id
  version                      = "1.18.8-aliyun.1"
  cluster_spec                 = var.cluster_spec
  rds_instances                = [var.rds_instance_id]
  worker_vswitch_ids           = var.ecs_vswitch_ids
  new_nat_gateway              = true
  worker_instance_types        = [var.worker_instance_type]
  worker_number                = length(var.ecs_vswitch_ids)
  worker_disk_category         = "cloud_essd"
  worker_disk_size             = var.worker_disk_size
  image_id                     = "centos_7_9_x64_20G_alibase_20201228.vhd"
  key_name                     = var.k8s_key_name
  pod_cidr                     = var.pod_cidr
  service_cidr                 = var.service_cidr
  install_cloud_monitor        = true
  is_enterprise_security_group = true
  load_balancer_spec           = var.load_balancer_spec
  runtime = {
    name    = "docker"
    version = "19.03.5"
  }
  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", local.full_cluster_addons)
      config = lookup(addons.value, "config", local.full_cluster_addons)
    }
  }
  tags = var.tags
}