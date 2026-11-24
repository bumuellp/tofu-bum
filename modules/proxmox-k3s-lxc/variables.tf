variable "node_name" {
  description = "Proxmox VE node name where the LXC container will be created."
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "Numeric Proxmox container ID (CTID)."
  type        = number
  default     = 200
}

variable "hostname" {
  description = "Hostname assigned to the LXC container."
  type        = string
  default     = "k3s-core"
}

variable "description" {
  description = "Proxmox container description."
  type        = string
  default     = "Managed by OpenTofu — K3s LXC node"
}

variable "tags" {
  description = "Tags applied to the Proxmox container."
  type        = list(string)
  default     = ["k3s", "opentofu"]
}

variable "unprivileged" {
  description = "Whether the LXC container is unprivileged. Set to false for nested K3s + GPU/CNI access."
  type        = bool
  default     = false
}

variable "nesting" {
  description = "Enable container nesting (required for containerd inside K3s)."
  type        = bool
  default     = true
}

variable "keyctl" {
  description = "Enable keyctl feature (only supported by Proxmox on unprivileged containers)."
  type        = bool
  default     = false
}

variable "cpu_cores" {
  description = "Number of CPU cores allocated to the container."
  type        = number
  default     = 12
}

variable "memory_dedicated_mb" {
  description = "Dedicated RAM ceiling in MiB."
  type        = number
  default     = 118784
}

variable "memory_swap_mb" {
  description = "Swap allocation in MiB."
  type        = number
  default     = 0
}

variable "disk_datastore_id" {
  description = "Proxmox storage pool ID for the container rootfs."
  type        = string
  default     = "local-zfs"
}

variable "disk_size_gb" {
  description = "Rootfs disk size in GiB."
  type        = number
  default     = 120
}

variable "template_file_id" {
  description = "Proxmox LXC template ID (e.g. local:vztmpl/debian-13-standard_13.0-1_amd64.tar.zst)."
  type        = string
}

variable "os_type" {
  description = "LXC OS type."
  type        = string
  default     = "debian"
}

variable "network_bridge" {
  description = "Proxmox host bridge interface."
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "IPv4 CIDR address (e.g. 192.168.1.50/24) or 'dhcp'."
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway (required when ipv4_address is static)."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS server IPs for the container."
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "ssh_public_keys" {
  description = "List of SSH public keys injected into the root account on creation."
  type        = list(string)
  default     = []
}

variable "device_passthroughs" {
  description = "Host device nodes passed into the LXC container (e.g. AMD /dev/kfd and /dev/dri/*)."
  type = list(object({
    path       = string
    uid        = optional(number)
    gid        = optional(number)
    mode       = optional(string, "0660")
    deny_write = optional(bool, false)
  }))
  default = [
    {
      path = "/dev/kfd"
      mode = "0666"
    },
    {
      path = "/dev/dri/renderD128"
      mode = "0666"
    },
    {
      path = "/dev/dri/card0"
      mode = "0666"
    },
  ]
}

variable "mount_points" {
  description = "Host directory or Proxmox volume bind mounts attached to the LXC container."
  type = list(object({
    volume    = string
    path      = string
    read_only = optional(bool, false)
    backup    = optional(bool, false)
  }))
  default = []
}

variable "start_on_boot" {
  description = "Whether the container starts automatically on Proxmox host boot."
  type        = bool
  default     = true
}

variable "started" {
  description = "Whether the container should be running after creation."
  type        = bool
  default     = true
}
