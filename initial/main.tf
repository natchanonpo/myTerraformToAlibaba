terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.3"
    }
  }
}

provider "alicloud" {
  // The access key, secret key and region are provided from environment variables
}

resource "alicloud_oss_bucket" "tf-state" {
  bucket = lower("XOM-BCS-SHARED-OSS-TFSTATE")
  acl    = "private"

  versioning {
    status = "Enabled"
  }

  tags = {
    application = "infrastructure"
  }
}

