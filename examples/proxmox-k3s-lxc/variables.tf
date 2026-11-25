variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint URL."
  type        = string
  default     = "https://192.0.2.10:8006/"
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token (root@pam recommended for privileged LXC passthrough)."
  type        = string
  sensitive   = true
  default     = "root@pam!tofu-token=00000000-0000-0000-0000-000000000000"
}

variable "ssh_public_key" {
  description = "SSH public key for root bootstrap access."
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKey user@workstation"
}
