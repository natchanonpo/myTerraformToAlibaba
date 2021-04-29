environment = "NONPROD"
cluster_addons = [
  {
    "name"   = "nginx-ingress-controller",
    "config" = "{\"IngressSlbNetworkType\":\"internet\"}",
  },
  {
    "name"   = "logtail-ds",
    "config" = "{\"IngressDashboardEnabled\":\"true\",\"sls_project_name\":\"XOM-BCS-NONPROD-SLS\"}",
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