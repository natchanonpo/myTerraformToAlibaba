terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.3"
    }
  }
  backend "oss" {
    bucket = "xom-bcs-nonprod-oss-tfstate"
    prefix = "nonprod/tfstate"
    region = "cn-shanghai"
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

//VPC
resource "alicloud_vpc" "vpc" {
  resource_group_id = var.resource_group_id
  count             = 1
  vpc_name          = "XOM-BCS-${var.environment}-VPC"
  cidr_block        = "192.168.0.0/16"
  tags              = local.tags
}

resource "alicloud_vswitch" "ecs_vswitchs" {
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
  resource_group_id = var.resource_group_id
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
  name                         = "XOM-BCS-${var.environment}-K8S"
  resource_group_id            = var.resource_group_id
  version                      = "1.18.8-aliyun.1"
  cluster_spec                 = "ack.pro.small"
  rds_instances                = [alicloud_db_instance.rds_instance.id]
  worker_vswitch_ids           = split(",", join(",", alicloud_vswitch.ecs_vswitchs.*.id))
  new_nat_gateway              = true
  worker_instance_types        = ["ecs.g6.xlarge"]
  worker_number                = 3
  worker_disk_category         = "cloud_essd"
  worker_disk_size             = "120"
  image_id                     = "centos_7_9_x64_20G_alibase_20201228.vhd"
  key_name                     = "XOM-BCS-${var.environment}-K8S-WORKER-KEY"
  pod_cidr                     = "172.20.0.0/16"
  service_cidr                 = "172.21.0.0/20"
  install_cloud_monitor        = true
  is_enterprise_security_group = true
  load_balancer_spec           = "slb.s2.small"
  runtime = {
    name    = "docker"
    version = "19.03.5"
  }
  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }
  tags = local.tags
}


//grant cluster read-only permission for alibaba console role
resource "alicloud_ram_policy" "cluster-read-only" {
  policy_name     = "cluster-read-only"
  policy_document = <<EOF
  {
    "Statement": [{
      "Action": [
         "cs:Get*"
         ],
      "Effect": "Allow",
      "Resource": [
         "acs:cs:*:*:cluster/${alicloud_cs_managed_kubernetes.k8s.id}"
      ]
    }],
    "Version": "1"
  }
  EOF
  description     = "read only policy for K8S"
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.cluster-read-only.name
  policy_type = alicloud_ram_policy.cluster-read-only.type
  role_name   = "flcit-chemicalchina-dev-xom-editor"
}
