output "id" {
  description = "ID of the Hetzner server"
  value       = hcloud_server.this.id
}

output "name" {
  description = "Name of the Hetzner server"
  value       = hcloud_server.this.name
}

output "ipv4_address" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.this.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address of the server"
  value       = hcloud_server.this.ipv6_address
}

output "status" {
  description = "Status of the server"
  value       = hcloud_server.this.status
}

output "volume_attachment_id" {
  description = "ID of the volume attachment, if a volume was attached"
  value       = try(hcloud_volume_attachment.this[0].id, null)
}
