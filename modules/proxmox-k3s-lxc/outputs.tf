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
  value       = var.hostname
}

output "ipv4_addresses" {
  description = "IPv4 addresses assigned to the container network interfaces."
  value       = proxmox_virtual_environment_container.this.ipv4
}

output "mac_address" {
  description = "MAC address of eth0."
  value       = try(proxmox_virtual_environment_container.this.network_interface[0].mac_address, null)
}
