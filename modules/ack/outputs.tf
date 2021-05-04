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