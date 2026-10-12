resource "hcloud_volume" "this" {
  name              = var.name
  size              = var.size
  location          = var.location
  format            = var.format
  delete_protection = var.delete_protection
  labels            = var.labels
}
