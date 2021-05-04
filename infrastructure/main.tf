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
  tags = {
    Environment = var.environment
    Application = "BCS"
  }
}

module "vpc" {
  source = "../modules/vpc"
  name   = "XOM-${var.project_name}-${var.environment}-VPC"
  cidr   = var.vpc_cidr
  tags   = local.tags
}

module "vswitchs" {
  source             = "../modules/vswitchs"
  vpc_id             = vpc.vpc_id
  ecs_cidrs          = var.ecs_vswitch_cidrs
  rds_cidrs          = var.rds_vswitch_cidr
  kafka_cidrs        = var.kafka_vswitch_cidr
  ecs_zone_ids       = var.ecs_vswitch_zone_ids
  rds_zone_ids       = var.rds_vswitch_zone_ids
  kafka_zone_ids     = var.kafka_vswitch_zone_ids
  names_prefix       = "XOM-${var.project_name}-${var.environment}"
  ecs_names_suffix   = "node"
  rds_names_suffix   = "database"
  kafka_names_suffix = "kafka"
  tags               = local.tags
}

module "rds" {
  source           = "../modules/rds"
  instance_name    = "XOM-${var.project_name}-${var.environment}-RDS"
  instance_type    = var.rds_instance_type
  instance_storage = var.rds_instance_storage
  vswitch_id       = module.vswitchs.rds_vswitch_ids[0].id
  db_name_template = "XOM-${var.project_name}-%s-DATABASE-%s"
  db_names         = var.db_names
  db_envs          = var.db_envs
  tags             = local.tags
}

module "kafka" {
  source      = "../modules/kafka"
  name        = "XOM-${var.project_name}-${var.environment}-MQ"
  topic_quota = var.kafka_topic_quota
  disk_size   = var.kafka_disk_size
  io_max      = var.kafka_io_max
  eip_max     = var.kafka_eip_max
  vswitch_id  = module.vswitchs.kafka_vswitch_ids[0].id
  tags        = local.tags
}

module "ack" {
  source               = "../modules/ack"
  log_name             = "XOM-${var.project_name}-${var.environment}-SLS"
  k8s_name             = "XOM-${var.project_name}-${var.environment}-K8S"
  k8s_key_name         = "XOM-${var.project_name}-${var.environment}-K8S-WORKER-KEY"
  cluster_spec         = var.k8s_cluster_spec
  ecs_vswitch_ids      = module.vswitchs.ecs_vswitch_ids
  rds_instance_id      = module.rds.instance_id
  worker_instance_type = var.k8s_worker_instance_type
  load_balancer_spec   = var.k8s_load_balancer_spec
  worker_disk_size     = var.k8s_worker_disk_size
  cluster_addons       = var.k8s_cluster_addons
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