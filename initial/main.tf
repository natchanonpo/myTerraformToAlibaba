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

data "alicloud_oss_service" "open" {
  enable = "On"
}

resource "alicloud_oss_bucket" "tf-state" {
  bucket = lower("test-xom-ecomm-bcs-shared-oss001-tfstate")
  acl    = "private"

  versioning {
    status = "Enabled"
  }

  tags = {
    application = "infrastructure"
  }
}

