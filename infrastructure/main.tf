terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = "1.121.1"
    }
  }
  backend "oss" {
    bucket = "xom-bcs-terraform-test"
    region = "cn-shanghai"
    // The access key is provided from ALICLOUD_ACCESS_KEY environment variable
    // The secret key is provided from ALICLOUD_SECRET_KEY environment variable
  }
}

provider "alicloud" {
  region = "cn-shanghai"
  // The access key is provided from ALICLOUD_ACCESS_KEY environment variable
  // The secret key is provided from ALICLOUD_SECRET_KEY environment variable
}

locals {
  k8s_name          = "tf-cluster-poc"
  new_vpc_name      = "vpc-for-${local.k8s_name}"
  log_project_name  = "log-for-${local.k8s_name}"
  db_instance_name  = "poc-tw-test-db"
  db_name           = "test-db"
}

data "alicloud_instance_types" "default" {
  cpu_core_count       = 4
  memory_size          = 8
  kubernetes_node_role = "Worker"
}

data "alicloud_zones" "default" {
  available_instance_type = data.alicloud_instance_types.default.instance_types[0].id
}

//VPC
resource "alicloud_vpc" "default" {
  count      = 1
  vpc_name   = local.new_vpc_name
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "vswitches" {
  count             = 3
  vpc_id            = alicloud_vpc.default[0].id
  cidr_block        = element(["192.168.0.0/19", "192.168.64.0/19", "192.168.96.0/20"], count.index)
  zone_id           = element(data.alicloud_zones.default.zones.*.id, count.index)
}

//RDS
resource "alicloud_db_instance" "instance" {
  engine           = "MySQL"
  engine_version   = "8.0"
  instance_type    = "rds.mysql.s1.small"
  instance_storage = "10"
  vswitch_id       = alicloud_vswitch.vswitches[2].id
  instance_name    = local.db_instance_name
}

resource "alicloud_db_database" "default" {
  instance_id = alicloud_db_instance.instance.id
  name        = local.db_name
}

//ACK
resource "alicloud_log_project" "log" {
  name        = local.log_project_name
  description = "created by terraform for managedkubernetes cluster"
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  name                      = local.k8s_name
  version                   = "1.18.8-aliyun.1"
  cluster_spec              = "ack.pro.small"
  rds_instances             = [alicloud_db_instance.instance.id]
  worker_vswitch_ids        = split(",", join(",", alicloud_vswitch.vswitches.*.id))
  new_nat_gateway           = true
  worker_instance_types     = [data.alicloud_instance_types.default.instance_types[0].id]
  worker_number             = 3
  password                  = "Yourpassword1234"
  pod_cidr                  = "172.20.0.0/16"
  service_cidr              = "172.21.0.0/20"
  install_cloud_monitor     = true
  slb_internet_enabled      = true
  worker_disk_category      = "cloud_efficiency"

  runtime = {
    name = "docker"
    version = "19.03.5"
  }

  addons {
    name     = "logtail-ds"
    config   = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":alicloud_log_project.log.name}"
  }
}
