module "k3s_core" {
  source = "../../modules/proxmox-k3s-lxc"

  node_name           = "pve"
  vm_id               = 200
  hostname            = "k3s-core"
  template_file_id    = "local:vztmpl/debian-13-standard_13.0-1_amd64.tar.zst"
  cpu_cores           = 12
  memory_dedicated_mb = 118784
  disk_datastore_id   = "local-zfs"
  disk_size_gb        = 120
  ipv4_address        = "192.0.2.50/24"
  ipv4_gateway        = "192.0.2.1"
  ssh_public_keys     = [var.ssh_public_key]

  device_passthroughs = [
    { path = "/dev/kfd", mode = "0660" },
    { path = "/dev/dri/renderD128", mode = "0660" },
    { path = "/dev/dri/card0", mode = "0660" },
  ]

  mount_points = [
    {
      volume = "/srv/llm-models"
      path   = "/srv/llm-models"
    }
  ]
}
