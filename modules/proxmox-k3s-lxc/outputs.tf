output "id" {
  description = "Full Proxmox container resource ID."
  value       = proxmox_virtual_environment_container.this.id
}

output "vm_id" {
  description = "Numeric Proxmox container ID."
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "node_name" {
  description = "Proxmox node hosting the container."
  value       = proxmox_virtual_environment_container.this.node_name
}

output "hostname" {
  description = "Container hostname."
  value       = try(proxmox_virtual_environment_container.this.initialization[0].hostname, var.hostname)
}

output "ipv4_address" {
  description = "Primary IPv4 address assigned to eth0."
  value       = try(proxmox_virtual_environment_container.this.ipv4["eth0"], null)
}

output "ipv4_addresses" {
  description = "Map of interface names to assigned IPv4 addresses."
  value       = proxmox_virtual_environment_container.this.ipv4
}

output "mac_address" {
  description = "MAC address of eth0."
  value       = try(proxmox_virtual_environment_container.this.network_interface[0].mac_address, null)
}
