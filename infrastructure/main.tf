terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.122.1"
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
    Application = var.project_name
  }
}

# module "services_enabling" {
#   source = "../modules/services-enabling"
# }

# module "resource_group" {
#   //Deleting resource group take 7 days to be finish!!
#   source = "../modules/resource-group"
#   name   = "${local.prefix}-RSG002"
# }

# module "kms" {
#   source = "../modules/kms"
#   name   = "${local.prefix}-KMS-ALIAS-001"
# }

# module "vpc" {
#   source            = "../modules/vpc"
#   name              = "${local.prefix}-VPC001"
#   resource_group_id = module.resource_group.resource_group_id
#   cidr              = var.vpc_cidr
#   tags              = local.tags
# }

# module "vswitchs" {
#   source             = "../modules/vswitchs"
#   vpc_id             = module.vpc.vpc_id
#   ecs_cidrs          = var.ecs_vswitch_cidrs
#   rds_cidrs          = var.rds_vswitch_cidrs
#   kafka_cidrs        = var.kafka_vswitch_cidrs
#   ecs_zone_ids       = var.ecs_vswitch_zone_ids
#   rds_zone_ids       = var.rds_vswitch_zone_ids
#   kafka_zone_ids     = var.kafka_vswitch_zone_ids
#   names_prefix       = "${local.prefix}-SNT"
#   ecs_names_suffix   = "node"
#   rds_names_suffix   = "database"
#   kafka_names_suffix = "kafka"
#   tags               = local.tags
# }

module "rds_dev_sit" {
  source = "../modules/rds"
  # resource_group_id = module.resource_group.resource_group_id
  instance_name    = "${local.prefix}-RDS001"
  instance_type    = var.rds_instance_type
  instance_storage = var.rds_instance_storage
  # vswitch_id                 = module.vswitchs.rds_vswitch_ids[0]
  db_name_template = "XOM-${var.project_name}-%s-DATABASE%03s-%s"
  db_names         = var.db_names
  # db_envs                    = var.db_envs
  db_envs                  = var.db_envs_dev_sit
  db_allowed_external_envs = var.db_allowed_external_envs
  # xom_editor_password        = var.db_xom_editor_password
  # xom_readonly_password      = var.db_xom_readonly_password
  # external_editor_password   = var.db_external_editor_password
  # external_readonly_password = var.db_external_readonly_password
  tags = local.tags
}

module "rds_acc" {
  source = "../modules/rds"
  # resource_group_id = module.resource_group.resource_group_id
  instance_name    = "${local.prefix}-RDS002"
  instance_type    = var.rds_instance_type
  instance_storage = var.rds_instance_storage
  # vswitch_id                 = module.vswitchs.rds_vswitch_ids[0]
  db_name_template = "XOM-${var.project_name}-%s-DATABASE%03s-%s"
  db_names         = var.db_names
  # db_envs                    = var.db_envs
  db_envs = var.db_envs_acc
  # db_allowed_external_envs = var.db_allowed_external_envs
  # xom_editor_password        = var.db_xom_editor_password
  # # xom_readonly_password      = var.db_xom_readonly_password
  # external_editor_password   = var.db_external_editor_password
  # external_readonly_password = var.db_external_readonly_password
  tags = local.tags
}

# module "kafka" {
#   source      = "../modules/kafka"
#   name        = "${local.prefix}-MQ001"
#   topic_quota = var.kafka_topic_quota
#   disk_size   = var.kafka_disk_size
#   io_max      = var.kafka_io_max
#   eip_max     = var.kafka_eip_max
#   vswitch_id  = module.vswitchs.kafka_vswitch_ids[0]
#   tags        = local.tags
# }

# module "ack" {
#   depends_on = [
#     module.services_enabling
#   ]
#   source                  = "../modules/ack"
#   log_name                = "${local.prefix}-SLS001"
#   k8s_name                = "${local.prefix}-K8S001"
#   k8s_key_name            = "${local.prefix}-K8S001-WORKER-KEY"
#   resource_group_id       = module.resource_group.resource_group_id
#   cluster_spec            = var.k8s_cluster_spec
#   ecs_vswitch_ids         = module.vswitchs.ecs_vswitch_ids
#   rds_instance_id         = module.rds.instance_id
#   worker_instance_type    = var.k8s_worker_instance_type
#   load_balancer_spec      = var.k8s_load_balancer_spec
#   worker_disk_size        = var.k8s_worker_disk_size
#   cluster_addons          = var.k8s_cluster_addons
#   pod_cidr                = var.k8s_pod_cidr
#   service_cidr            = var.k8s_service_cidr
#   ops_role                = var.k8s_ops_role
#   tags                    = local.tags
#   encryption_provider_key = module.kms.kms_k8s_key_id
# }
