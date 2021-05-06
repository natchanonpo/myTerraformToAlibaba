environment  = "PRODUCTION"
project_name = "ECOMM-BCS"
cluster_addons = [
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