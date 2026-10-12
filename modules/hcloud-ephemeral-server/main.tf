resource "hcloud_server" "this" {
  name         = var.name
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  user_data    = var.user_data
  firewall_ids = var.firewall_ids
  ssh_keys     = var.ssh_keys
  labels       = var.labels
}

resource "hcloud_volume_attachment" "this" {
  count     = var.volume_id != null ? 1 : 0
  volume_id = var.volume_id
  server_id = hcloud_server.this.id
  automount = var.automount_volume
}
