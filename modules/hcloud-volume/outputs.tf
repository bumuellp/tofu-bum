output "id" {
  description = "ID of the persistent volume"
  value       = hcloud_volume.this.id
}

output "name" {
  description = "Name of the persistent volume"
  value       = hcloud_volume.this.name
}

output "size" {
  description = "Size of the volume in GB"
  value       = hcloud_volume.this.size
}

output "linux_device" {
  description = "Predictable Linux device path when attached to a server"
  value       = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.this.id}"
}
