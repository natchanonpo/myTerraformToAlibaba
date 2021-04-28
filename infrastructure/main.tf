terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.1"
    }
  }
  backend "oss" {
    bucket = "XOM-BCS-NONPROD-OSS-TFSTATE"
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

data "alicloud_zones" "ecs" {
  available_instance_type = "ecs.g6.xlarge"
}

data "alicloud_zones" "rds" {
  available_resource_creation = "Rds"
}

//VPC
resource "alicloud_vpc" "nonprod" {
  resource_group_id = local.resource_group_id
  count             = 1
  vpc_name          = "XOM-BCS-NONPROD-VPC"
  cidr_block        = "192.168.0.0/16"
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}

resource "alicloud_vswitch" "ecs" {
  count             = 3
  vpc_id            = alicloud_vpc.nonprod[0].id
  cidr_block        = element(["192.168.0.0/19", "192.168.64.0/19", "192.168.96.0/20"], count.index)
  vswitch_name      = element(["XOM-BCS-NONPROD-SNT1-node", "XOM-BCS-NONPROD-SNT2-node", "XOM-BCS-NONPROD-SNT3-node"], count.index)
  zone_id           = element(data.alicloud_zones.ecs.zones.*.id, count.index)
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}

resource "alicloud_vswitch" "rds" {
  count             = 1
  vpc_id            = alicloud_vpc.nonprod[0].id
  cidr_block        = "192.168.112.0/21"
  vswitch_name      = "XOM-BCS-NONPROD-SNT4-database"
  zone_id           = data.alicloud_zones.rds.zones.0.id
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}

//RDS
resource "alicloud_db_instance" "nonprod" {
  resource_group_id         = local.resource_group_id
  engine           = "MySQL"
  engine_version   = "8.0"
  instance_type    = "rds.mysql.s2.large"
  instance_storage = "50"
  vswitch_id       = alicloud_vswitch.rds[0].id
  instance_name    = "XOM-BCS-NONPROD-RDS"
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}

resource "alicloud_db_database" "dev" {
  instance_id = alicloud_db_instance.nonprod.id
  name        = "XOM-BCS-DEV-DATABASE-PROJECT_TEMPLATE"
}

resource "alicloud_db_database" "acc" {
  instance_id = alicloud_db_instance.nonprod.id
  name        = "XOM-BCS-ACC-DATABASE-PROJECT_TEMPLATE"
}

//ACK
resource "alicloud_log_project" "log" {
  name        = "XOM-BCS-NONPROD-SLS"
  description = "log for k8s"
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}

resource "alicloud_cs_managed_kubernetes" "k8s" {

  resource_group_id         = local.resource_group_id

  name                      = "XOM-BCS-NONPROD-K8S"

  version                   = "1.18.8-aliyun.1"

  cluster_spec              = "ack.pro.small"

  rds_instances             = [alicloud_db_instance.nonprod.id]

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
  tags              = {
    Environment = "NONPROD"
    Application = "BCS"
  }
}
