# `proxmox-k3s-lxc` Module

OpenTofu module wrapping `bpg/proxmox` (`proxmox_virtual_environment_container`) to provision a privileged, nesting-enabled LXC container for running K3s with host GPU device passthrough (`/dev/kfd`, `/dev/dri/*`) and optional host bind mounts.

## Features
- **Privileged + Nesting**: Defaults to `unprivileged = false` and `nesting = true` for nested `containerd` and eBPF/Flannel CNI compatibility.
- **Native GPU Device Passthrough**: Uses `bpg/proxmox` `device_passthrough` blocks (defaulting to `/dev/kfd`, `/dev/dri/renderD128`, `/dev/dri/card0`).
- **Host Bind Mounts**: Optional `mount_points` list for attaching un-snapshotted ZFS datasets (e.g., `/srv/llm-models`).

## Proxmox Host Post-Provision Note
`bpg/proxmox` does not expose raw LXC AppArmor or `memlock` prlimit directives as schema attributes. After provisioning (or via your Proxmox host bootstrap), ensure the following two lines exist in `/etc/pve/lxc/<vm_id>.conf` on the Proxmox host before starting K3s GPU workloads:

```ini
lxc.apparmor.profile: unconfined
lxc.prlimit.memlock: unlimited
```

## Example Usage

```hcl
module "k3s_core" {
  source = "git::https://github.com/bumuellp/tofu-bum.git//modules/proxmox-k3s-lxc?ref=v1.1.0"

  node_name           = "pve"
  vm_id               = 200
  hostname            = "k3s-core"
  template_file_id    = "local:vztmpl/debian-13-standard_13.0-1_amd64.tar.zst"
  cpu_cores           = 12
  memory_dedicated_mb = 118784
  disk_datastore_id   = "local-zfs"
  disk_size_gb        = 120
  ipv4_address        = "192.0.2.50/24"
  ipv4_gateway        = "192.0.2.1"
  ssh_public_keys     = [var.admin_ssh_public_key]

  mount_points = [
    {
      volume = "/srv/llm-models"
      path   = "/srv/llm-models"
      backup = false
    }
  ]
}
```
