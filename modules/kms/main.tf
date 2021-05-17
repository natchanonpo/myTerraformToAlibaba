resource "alicloud_kms_key" "kms_k8s_key" {
  description            = "K8S encrypted key"
  pending_window_in_days = "7" //The KMS key cannot be deleted immediately. There is a pending period here, 7 to 30 days are the valid range value.
  key_state              = "Enabled"
  key_spec               = "Aliyun_AES_256"
}

resource "alicloud_kms_alias" "kms_k8s_alias" {
  alias_name = "alias/${var.name}"
  key_id     = alicloud_kms_key.kms_k8s_key.id
}