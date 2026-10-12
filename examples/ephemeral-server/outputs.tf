output "server_ipv4" {
  description = "IPv4 address of provisioned server"
  value       = module.server.ipv4_address
}

output "volume_id" {
  description = "ID of persistent volume"
  value       = module.volume.id
}

output "firewall_id" {
  description = "ID of firewall"
  value       = module.firewall.id
}
