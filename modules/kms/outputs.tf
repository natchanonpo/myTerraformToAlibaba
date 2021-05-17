output "kms_k8s_key_id" {
  value = alicloud_kms_key.kms_k8s_key.id
}

output "kms_k8s_key_alias" {
  value = alicloud_kms_alias.kms_k8s_alias.id
}