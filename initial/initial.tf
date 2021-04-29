terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.121.3"
    }
  }
}

provider "alicloud" {
  region = "cn-shanghai"
  // The access key is provided from ALICLOUD_ACCESS_KEY environment variable
  // The secret key is provided from ALICLOUD_SECRET_KEY environment variable
}

resource "alicloud_oss_bucket" "infra-tf-state" {
  bucket = "XOM-BCS-OSS-TFSTATE"
  acl    = "private"

  versioning {
    status = "Enabled"
  }

  tags = {
    application = "infrastructure"
  }
}

