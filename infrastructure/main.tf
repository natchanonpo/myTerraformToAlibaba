terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.1"
    }
  }
  backend "oss" {
    // The access key, secret key and region are provided from environment variables
  }
}

provider "alicloud" {
  // The access key, secret key and region are provided from environment variables
}

locals {
  tags = {
    Environment = var.environment
    Application = "BCS"
  }
}

data "alicloud_zones" "ecs_zones" {
  available_instance_type = "ecs.g6.xlarge"
}

data "alicloud_zones" "rds_zones" {
  available_resource_creation = "Rds"
}

data "alicloud_resource_manager_resource_groups" "resource_group" {
  name_regex = var.resource_group_name
}

//VPC
resource "alicloud_vpc" "vpc" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_group.ids[0]
  count             = 1
  vpc_name          = "XOM-BCS-${var.environment}-VPC"
  cidr_block        = "192.168.0.0/16"
  tags              = local.tags
}

resource "alicloud_vswitch" "ecs_vswitch" {
  count        = 3
  vpc_id       = alicloud_vpc.vpc[0].id
  cidr_block   = element(["192.168.0.0/19", "192.168.64.0/19", "192.168.96.0/20"], count.index)
  vswitch_name = element(["XOM-BCS-${var.environment}-SNT1-node", "XOM-BCS-${var.environment}-SNT2-node", "XOM-BCS-${var.environment}-SNT3-node"], count.index)
  zone_id      = element(data.alicloud_zones.ecs_zones.zones.*.id, count.index)
  tags         = local.tags
}

resource "alicloud_vswitch" "rds_vswitch" {
  count        = 1
  vpc_id       = alicloud_vpc.vpc[0].id
  cidr_block   = "192.168.112.0/21"
  vswitch_name = "XOM-BCS-${var.environment}-SNT4-database"
  zone_id      = data.alicloud_zones.rds_zones.zones.0.id
  tags         = local.tags
}

//RDS
resource "alicloud_db_instance" "rds_instance" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.resource_group.ids[0]
  engine            = "MySQL"
  engine_version    = "8.0"
  instance_type     = "rds.mysql.s2.large"
  instance_storage  = "50"
  vswitch_id        = alicloud_vswitch.rds_vswitch[0].id
  instance_name     = "XOM-BCS-${var.environment}-RDS"
  tags              = local.tags
}

resource "alicloud_db_database" "dev" {
  instance_id = alicloud_db_instance.rds_instance.id
  name        = lower("XOM-BCS-DEV-DATABASE-PROJECT_TEMPLATE")
}

resource "alicloud_db_database" "acc" {
  instance_id = alicloud_db_instance.rds_instance.id
  name        = lower("XOM-BCS-ACC-DATABASE-PROJECT_TEMPLATE")
}

//ACK
resource "alicloud_log_project" "log" {
  name        = "XOM-BCS-${var.environment}-SLS"
  description = "log for k8s"
  tags        = local.tags
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  resource_group_id     = data.alicloud_resource_manager_resource_groups.resource_group.ids[0]
  name                  = "XOM-BCS-${var.environment}-K8S"
  version               = "1.18.8-aliyun.1"
  cluster_spec          = "ack.pro.small"
  rds_instances         = [alicloud_db_instance.rds_instance.id]
  worker_vswitch_ids    = split(",", join(",", alicloud_vswitch.vswitches.*.id))
  new_nat_gateway       = true
  worker_instance_types = [data.alicloud_instance_types.default.instance_types[0].id]
  worker_number         = 3
  password              = "Yourpassword1234"
  pod_cidr              = "172.20.0.0/16"
  service_cidr          = "172.21.0.0/20"
  install_cloud_monitor = true
  slb_internet_enabled  = true
  worker_disk_category  = "cloud_efficiency"
  runtime = {
    name    = "docker"
    version = "19.03.5"
  }
  addons {
    name   = "logtail-ds"
    config = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":alicloud_log_project.log.name}"
  }
  tags = local.tags
}
