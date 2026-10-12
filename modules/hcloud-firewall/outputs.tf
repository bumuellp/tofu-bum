output "id" {
  description = "ID of the Hetzner firewall"
  value       = hcloud_firewall.this.id
}

output "name" {
  description = "Name of the Hetzner firewall"
  value       = hcloud_firewall.this.name
}
