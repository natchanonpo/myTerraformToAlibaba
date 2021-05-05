terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.3"
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
  prefix = "XOM-${var.project_name}-${var.environment}"
  tags = {
    Environment = var.environment
    Application = "ECOMM-BCS"
  }
}

module "vpc" {
  source            = "../modules/vpc"
  name              = "${local.prefix}-VPC001"
  resource_group_id = var.resource_group_id
  cidr              = var.vpc_cidr
  tags              = local.tags
}

module "vswitchs" {
  source             = "../modules/vswitchs"
  vpc_id             = module.vpc.vpc_id
  ecs_cidrs          = var.ecs_vswitch_cidrs
  rds_cidrs          = var.rds_vswitch_cidrs
  kafka_cidrs        = var.kafka_vswitch_cidrs
  ecs_zone_ids       = var.ecs_vswitch_zone_ids
  rds_zone_ids       = var.rds_vswitch_zone_ids
  kafka_zone_ids     = var.kafka_vswitch_zone_ids
  names_prefix       = "${local.prefix}-SNT"
  ecs_names_suffix   = "node"
  rds_names_suffix   = "database"
  kafka_names_suffix = "kafka"
  tags               = local.tags
}

module "rds" {
  source            = "../modules/rds"
  resource_group_id = var.resource_group_id
  instance_name     = "${local.prefix}-RDS001"
  instance_type     = var.rds_instance_type
  instance_storage  = var.rds_instance_storage
  vswitch_id        = module.vswitchs.rds_vswitch_ids[0]
  db_name_template  = "XOM-${var.project_name}-%s-DATABASE%03s-%s"
  db_names          = var.db_names
  db_envs           = var.db_envs
  tags              = local.tags
}

module "kafka" {
  source      = "../modules/kafka"
  name        = "${local.prefix}-MQ001"
  topic_quota = var.kafka_topic_quota
  disk_size   = var.kafka_disk_size
  io_max      = var.kafka_io_max
  eip_max     = var.kafka_eip_max
  vswitch_id  = module.vswitchs.kafka_vswitch_ids[0]
  tags        = local.tags
}

module "ack" {
  source               = "../modules/ack"
  log_name             = "${local.prefix}-SLS001"
  k8s_name             = "${local.prefix}-K8S001"
  k8s_key_name         = "${local.prefix}-K8S001-WORKER-KEY"
  resource_group_id    = var.resource_group_id
  cluster_spec         = var.k8s_cluster_spec
  ecs_vswitch_ids      = module.vswitchs.ecs_vswitch_ids
  rds_instance_id      = module.rds.instance_id
  worker_instance_type = var.k8s_worker_instance_type
  load_balancer_spec   = var.k8s_load_balancer_spec
  worker_disk_size     = var.k8s_worker_disk_size
  cluster_addons       = var.k8s_cluster_addons
  pod_cidr             = var.k8s_pod_cidr
  service_cidr         = var.k8s_service_cidr
  tags                 = local.tags
}

//grant cluster read-only permission for alibaba console role
/*resource "alicloud_ram_policy" "cluster-read-only" {
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
*/