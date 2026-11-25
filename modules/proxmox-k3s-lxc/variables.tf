variable "node_name" {
  description = "Proxmox VE node name where the LXC container will be created."
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "Numeric Proxmox container ID (CTID). Defaults to null to let Proxmox auto-allocate the next free ID."
  type        = number
  default     = null

  validation {
    condition     = var.vm_id == null || (var.vm_id >= 100 && var.vm_id <= 999999999 && floor(var.vm_id) == var.vm_id)
    error_message = "vm_id must be null or an integer between 100 and 999999999."
  }
}

variable "hostname" {
  description = "Hostname assigned to the LXC container (valid DNS label)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.hostname))
    error_message = "hostname must be a valid lowercase DNS label (1-63 chars, alphanumeric or hyphen)."
  }
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
  default     = 4

  validation {
    condition     = var.cpu_cores >= 1 && floor(var.cpu_cores) == var.cpu_cores
    error_message = "cpu_cores must be an integer >= 1."
  }
}

variable "memory_dedicated_mb" {
  description = "Dedicated RAM ceiling in MiB."
  type        = number
  default     = 4096

  validation {
    condition     = var.memory_dedicated_mb >= 16 && floor(var.memory_dedicated_mb) == var.memory_dedicated_mb
    error_message = "memory_dedicated_mb must be an integer >= 16."
  }
}

variable "memory_swap_mb" {
  description = "Swap allocation in MiB."
  type        = number
  default     = 0

  validation {
    condition     = var.memory_swap_mb >= 0 && floor(var.memory_swap_mb) == var.memory_swap_mb
    error_message = "memory_swap_mb must be an integer >= 0."
  }
}

variable "disk_datastore_id" {
  description = "Proxmox storage pool ID for the container rootfs."
  type        = string
  default     = "local-zfs"
}

variable "disk_size_gb" {
  description = "Rootfs disk size in GiB."
  type        = number
  default     = 32

  validation {
    condition     = var.disk_size_gb >= 1 && floor(var.disk_size_gb) == var.disk_size_gb
    error_message = "disk_size_gb must be an integer >= 1."
  }
}

variable "template_file_id" {
  description = "Proxmox LXC template ID (e.g. local:vztmpl/debian-13-standard_13.0-1_amd64.tar.zst)."
  type        = string
}

variable "os_type" {
  description = "LXC OS type."
  type        = string
  default     = "debian"

  validation {
    condition     = contains(["alpine", "archlinux", "centos", "debian", "devuan", "fedora", "gentoo", "nixos", "opensuse", "ubuntu", "unmanaged"], var.os_type)
    error_message = "os_type must be a supported Proxmox LXC OS type."
  }
}

variable "network_bridge" {
  description = "Proxmox host bridge interface."
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "IPv4 CIDR address (e.g. 192.0.2.50/24) or 'dhcp'."
  type        = string
  default     = "dhcp"

  validation {
    condition     = var.ipv4_address == "dhcp" || can(cidrhost(var.ipv4_address, 0))
    error_message = "ipv4_address must be 'dhcp' or a valid IPv4 CIDR (e.g. 192.0.2.50/24)."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway (required when ipv4_address is static; must be null for dhcp)."
  type        = string
  default     = null

  validation {
    condition     = var.ipv4_gateway == null || can(cidrhost("${var.ipv4_gateway}/32", 0))
    error_message = "ipv4_gateway must be null or a valid IPv4 address."
  }
}

variable "dns_servers" {
  description = "List of DNS server IPs for the container. Pass [] to inherit host/DHCP DNS."
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "ssh_public_keys" {
  description = "List of SSH public keys injected into the root account on creation."
  type        = list(string)
  default     = []
}

variable "device_passthroughs" {
  description = "Host device nodes passed into the LXC container (e.g. /dev/kfd and /dev/dri/*)."
  type = list(object({
    path       = string
    uid        = optional(number)
    gid        = optional(number)
    mode       = optional(string, "0660")
    deny_write = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for d in var.device_passthroughs :
      startswith(d.path, "/dev/") && can(regex("^[0-7]{4}$", coalesce(d.mode, "0660")))
    ])
    error_message = "Each device_passthrough path must start with '/dev/' and mode must be a 4-digit octal string (e.g. '0660')."
  }
}

variable "mount_points" {
  description = "Host directory bind mounts (starting with '/') or Proxmox storage volume mount points."
  type = list(object({
    volume    = string
    path      = string
    size      = optional(string)
    read_only = optional(bool, false)
    backup    = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for m in var.mount_points :
      !(startswith(m.volume, "/") && (m.size != null || coalesce(m.backup, false)))
    ])
    error_message = "Host bind mounts (volume starting with '/') must not specify size or backup = true."
  }
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

variable "wait_for_ipv4" {
  description = "Wait for an IPv4 address to be reported after container startup."
  type        = bool
  default     = true
}
