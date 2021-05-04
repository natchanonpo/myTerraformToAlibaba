// Output VPC resource
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "ecs_vswitch_ids" {
  description = "List ID of the Node VSwitches."
  value       = [module.vswitchs.ecs_vswitch_ids]
}

output "rds_vswitch_ids" {
  description = "List ID of the Node VSwitches."
  value       = [module.vswitchs.rds_vswitch_ids]
}

output "kafka_vswitch_ids" {
  description = "List ID of the Node VSwitches."
  value       = [module.vswitchs.kafka_vswitch_ids]
}

// Output kubernetes resource
output "cluster_id" {
  description = "ID of the kunernetes cluster."
  value       = module.ack.cluster_id
}

output "cluster_name" {
  description = "Name of the kunernetes cluster."
  value       = module.ack.cluster_name
}

output "master_slb_intranet" {
  description = "The ID of private load balancer where the current cluster master node is located."
  value       = module.ack.master_slb_intranet
}

output "security_group_id" {
  description = "The ID of security group where the current cluster worker node is located."
  value       = module.ack.security_group_id
}

output "nat_gateway_id" {
  description = "The ID of nat gateway used to launch kubernetes cluster."
  value       = module.ack.nat_gateway_id
}

output "worker_nodes" {
  description = "List worker nodes of cluster."
  value       = [module.ack.worker_nodes]
}

output "connection_info" {
  description = "Map of kubernetes cluster connection information."
  value       = [module.ack.connection_info]
}

output "version" {
  description = "The Kubernetes server version for the cluster."
  value       = module.ack.version
}

output "worker_ram_role_name" {
  description = "The RamRole Name attached to worker node."
  value       = module.ack.worker_ram_role_name
}

output "certificate_authority" {
  description = "Nested attribute containing certificate authority data for your cluster."
  value       = module.ack.certificate_authority
}

//Output RDS resource
output "instance_id" {
  description = "The RDS instance ID."
  value       = module.rds.instance_id
}

output "rds_connection_port" {
  description = "RDS database connection port."
  value       = module.rds.instance_connection_port
}

output "rds_connection_string" {
  description = "RDS database connection string."
  value       = module.rds.instance_connection_string
}

output "rds_ssl_status" {
  description = "Status of the SSL feature. Yes: SSL is turned on; No: SSL is turned off."
  value       = module.rds.instance_ssl_status
}

output "database_id" {
  description = "The current database resource ID. Composed of instance ID and database name with format <instance_id>:<name>."
  value       = [module.rds.database_ids]
}