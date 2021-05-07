// Shared
environment  = "NONPROD"
project_name = "ECOMM-BCS"

// VPC
vpc_cidr = "192.168.0.0/16"

// VSwitch
ecs_vswitch_cidrs      = ["192.168.0.0/19", "192.168.64.0/19", "192.168.96.0/20"]
rds_vswitch_cidrs      = ["192.168.112.0/21"]
kafka_vswitch_cidrs    = ["192.168.151.0/24"]
ecs_vswitch_zone_ids   = ["cn-shanghai-b", "cn-shanghai-g", "cn-shanghai-l"]
rds_vswitch_zone_ids   = ["cn-shanghai-a"]
kafka_vswitch_zone_ids = ["cn-shanghai-a"]

// RDS
// In general for a production database, you’ll choose either High Availability or Enterprise, usually with ‘Local Disk”.
rds_instance_type    = "rds.mysql.s2.large"
rds_instance_storage = 50
db_names             = ["ORDER-TO-CASH", "USER", "CUSTOMER-SERVICE", "CRM", "PRODUCT"]
db_envs              = ["DEV", "STI", "ACC"]

// Kafka
kafka_disk_size   = 500
kafka_topic_quota = 50
kafka_io_max      = 20
kafka_eip_max     = 1

// ACK
k8s_cluster_spec         = "ack.pro.small"
k8s_worker_instance_type = "ecs.g6.xlarge"
k8s_load_balancer_spec   = "slb.s2.small"
k8s_pod_cidr             = "172.20.0.0/16"
k8s_service_cidr         = "172.21.0.0/20"
k8s_worker_disk_size     = 120
k8s_cluster_addons = [
  {
    "name"   = "nginx-ingress-controller",
    "config" = "{\"IngressSlbNetworkType\":\"internet\"}",
  },
  {
    "name"   = "csi-plugin",
    "config" = "",
  },
  {
    "name"   = "csi-provisioner",
    "config" = "",
  },
  {
    "name"   = "flannel",
    "config" = "",
  },
  {
    "name"   = "arms-prometheus",
    "config" = "",
  }
]