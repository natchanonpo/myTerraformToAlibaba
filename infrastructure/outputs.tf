// Output VPC resource
output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_cs_managed_kubernetes.k8s.vpc_id
}

output "vswitch_ids" {
  description = "List ID of the VSwitches."
  value       = [alicloud_cs_managed_kubernetes.k8s.vswitch_ids]
}

// Output kubernetes resource
output "cluster_id" {
  description = "ID of the kunernetes cluster."
  value       = alicloud_cs_managed_kubernetes.k8s.id
}

output "cluster_name" {
  description = "Name of the kunernetes cluster."
  value       = alicloud_cs_managed_kubernetes.k8s.name
}

output "master_slb_intranet" {
  description = "The ID of private load balancer where the current cluster master node is located."
  value       = alicloud_cs_managed_kubernetes.k8s.slb_intranet
}

output "security_group_id" {
  description = "The ID of security group where the current cluster worker node is located."
  value       = alicloud_cs_managed_kubernetes.k8s.security_group_id
}

output "nat_gateway_id" {
  description = "The ID of nat gateway used to launch kubernetes cluster."
  value       = alicloud_cs_managed_kubernetes.k8s.nat_gateway_id
}

output "worker_nodes" {
  description = "List worker nodes of cluster."
  value       = [alicloud_cs_managed_kubernetes.k8s.worker_nodes]
}

output "connection_info" {
  description = "Map of kubernetes cluster connection information."
  value       = [alicloud_cs_managed_kubernetes.k8s.connections]
}

output "version" {
  description = "The Kubernetes server version for the cluster."
  value       = alicloud_cs_managed_kubernetes.k8s.version
}

output "worker_ram_role_name" {
  description = "The RamRole Name attached to worker node."
  value       = alicloud_cs_managed_kubernetes.k8s.worker_ram_role_name
}

output "certificate_authority" {
  description = "Nested attribute containing certificate authority data for your cluster."
  value       = alicloud_cs_managed_kubernetes.k8s.certificate_authority
}

//Output RDS resource
output "instance_id" {
  description = "The RDS instance ID."
  value       = alicloud_db_instance.instance.id
}

output "rds_connection_port" {
  description = "RDS database connection port."
  value       = alicloud_db_instance.instance.port
}

output "rds_connection_string" {
  description = "RDS database connection string."
  value       = alicloud_db_instance.instance.connection_string
}

output "rds_ssl_status" {
  description = "Status of the SSL feature. Yes: SSL is turned on; No: SSL is turned off."
  value       = alicloud_db_instance.instance.ssl_status
}

output "database_id" {
  description = "The current database resource ID. Composed of instance ID and database name with format <instance_id>:<name>."
  value       = alicloud_db_database.default.id
}