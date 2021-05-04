output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_vpc.vpc.vpc_id
}