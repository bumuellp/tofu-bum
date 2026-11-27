mock_provider "proxmox" {}

variables {
  hostname         = "k3s-core"
  template_file_id = "local:vztmpl/debian-13-standard_13.0-1_amd64.tar.zst"
}

run "default_portable_configuration" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_container.this.unprivileged == false
    error_message = "Default container should be privileged for nested K3s."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.cpu[0].cores == 4
    error_message = "Default cpu_cores should be portable (4)."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.memory[0].dedicated == 4096
    error_message = "Default memory_dedicated_mb should be portable (4096)."
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.device_passthrough) == 0
    error_message = "device_passthroughs should default to empty for portability."
  }
}

run "amd_gpu_and_bind_mount" {
  command = plan

  variables {
    vm_id        = 200
    ipv4_address = "192.0.2.50/24"
    ipv4_gateway = "192.0.2.1"
    device_passthroughs = [
      { path = "/dev/kfd", mode = "0660" },
      { path = "/dev/dri/renderD128", mode = "0660" },
    ]
    mount_points = [
      { volume = "/srv/llm-models", path = "/srv/llm-models" },
    ]
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.device_passthrough) == 2
    error_message = "Expected 2 GPU device passthrough blocks."
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.mount_point) == 1
    error_message = "Expected 1 host bind mount point."
  }
}

run "reject_keyctl_on_privileged_container" {
  command = plan

  variables {
    unprivileged = false
    keyctl       = true
  }

  expect_failures = [
    proxmox_virtual_environment_container.this,
  ]
}

run "reject_gateway_with_dhcp" {
  command = plan

  variables {
    ipv4_address = "dhcp"
    ipv4_gateway = "192.0.2.1"
  }

  expect_failures = [
    proxmox_virtual_environment_container.this,
  ]
}

run "reject_invalid_device_mode" {
  command = plan

  variables {
    device_passthroughs = [
      { path = "/dev/kfd", mode = "invalid" },
    ]
  }

  expect_failures = [
    var.device_passthroughs,
  ]
}
