output "container_id" {
  description = "Full Proxmox container resource ID."
  value       = module.k3s_core.id
}

output "vm_id" {
  description = "Proxmox container ID."
  value       = module.k3s_core.vm_id
}

output "ipv4_address" {
  description = "Assigned IPv4 address on eth0."
  value       = module.k3s_core.ipv4_address
}
