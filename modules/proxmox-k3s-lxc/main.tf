resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.node_name
  vm_id         = var.vm_id
  description   = var.description
  tags          = var.tags
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = var.started

  features {
    nesting = var.nesting
    keyctl  = var.keyctl
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

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
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
      read_only = mount_point.value.read_only
      backup    = mount_point.value.backup
    }
  }
}
