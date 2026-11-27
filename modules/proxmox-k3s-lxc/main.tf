resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.node_name
  vm_id         = var.vm_id
  description   = var.description
  tags          = sort(distinct(var.tags))
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = var.started

  features {
    nesting = var.nesting
    keyctl  = var.unprivileged ? var.keyctl : null
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_dedicated_mb
    swap      = var.memory_swap_mb
  }

  disk {
    datastore_id = var.disk_datastore_id
    size         = var.disk_size_gb
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  initialization {
    hostname = var.hostname

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_address == "dhcp" ? null : var.ipv4_gateway
      }
    }

    dynamic "user_account" {
      for_each = length(var.ssh_public_keys) > 0 ? [1] : []
      content {
        keys = var.ssh_public_keys
      }
    }
  }

  dynamic "device_passthrough" {
    for_each = var.device_passthroughs
    content {
      path       = device_passthrough.value.path
      uid        = device_passthrough.value.uid
      gid        = device_passthrough.value.gid
      mode       = device_passthrough.value.mode
      deny_write = device_passthrough.value.deny_write
    }
  }

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      volume    = mount_point.value.volume
      path      = mount_point.value.path
      size      = startswith(mount_point.value.volume, "/") ? null : mount_point.value.size
      read_only = mount_point.value.read_only
      backup    = startswith(mount_point.value.volume, "/") ? null : mount_point.value.backup
    }
  }

  wait_for_ip {
    ipv4 = var.started && var.wait_for_ipv4
  }

  lifecycle {
    precondition {
      condition     = !(var.keyctl && !var.unprivileged)
      error_message = "Proxmox only supports keyctl = true on unprivileged containers (unprivileged = true)."
    }

    precondition {
      condition     = !(var.ipv4_address == "dhcp" && var.ipv4_gateway != null)
      error_message = "ipv4_gateway must be null when ipv4_address is 'dhcp'."
    }
  }
}
