# `proxmox-k3s-lxc` Module

OpenTofu module wrapping `bpg/proxmox` (`proxmox_virtual_environment_container`) to provision a privileged, nesting-enabled LXC container for running K3s with optional host GPU device passthrough (`/dev/kfd`, `/dev/dri/*`) and host bind mounts.

## Features
- **Privileged + Nesting**: Defaults to `unprivileged = false` and `nesting = true` for nested `containerd` and eBPF/Flannel CNI compatibility.
- **Opt-In GPU Device Passthrough**: Uses `bpg/proxmox` `device_passthrough` blocks (defaults to `[]` for host portability; pass AMD/Intel/NVIDIA device nodes explicitly with `mode = "0660"` and host `gid`).
- **Host Bind Mounts & Volume Mounts**: Supports both host directory bind mounts (e.g., `/srv/llm-models`) and Proxmox storage volume mounts (`size` + `backup`).

## Proxmox Host Prerequisites & Post-Provision Note
- **Authentication (`root@pam`)**: Proxmox's API restricts privileged LXC `features`, `device_passthrough`, and host bind `mount_points` to `root@pam`. Generate a `root@pam` token (`pveum user token add root@pam tofu-token --privsep=0`).
- **Host Config & Initial Boot**: `bpg/proxmox` does not expose raw LXC AppArmor or `memlock` prlimit directives as schema attributes. Either pass `started = false` on initial apply or restart the container after appending these two lines to `/etc/pve/lxc/<vm_id>.conf` on the Proxmox host:

```ini
lxc.apparmor.profile: unconfined
lxc.prlimit.memlock: unlimited
```

## Example Usage (with AMD GPU Passthrough)

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

  device_passthroughs = [
    { path = "/dev/kfd", mode = "0660" },
    { path = "/dev/dri/renderD128", mode = "0660" },
    { path = "/dev/dri/card0", mode = "0660" },
  ]

  mount_points = [
    {
      volume = "/srv/llm-models"
      path   = "/srv/llm-models"
    }
  ]
}
```

## Inputs

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `hostname` | `string` | *(required)* | Valid lowercase DNS label for the container. |
| `template_file_id` | `string` | *(required)* | Proxmox LXC template ID. |
| `node_name` | `string` | `"pve"` | Target Proxmox node name. |
| `vm_id` | `number` | `null` | Numeric CTID (`>= 100`), or `null` to auto-allocate. |
| `unprivileged` | `bool` | `false` | Privileged (`false`) or unprivileged (`true`). |
| `nesting` | `bool` | `true` | Enable container nesting. |
| `keyctl` | `bool` | `false` | Enable `keyctl` (only valid when `unprivileged = true`). |
| `cpu_cores` | `number` | `4` | CPU cores allocated. |
| `memory_dedicated_mb` | `number` | `4096` | RAM ceiling in MiB. |
| `disk_datastore_id` | `string` | `"local-zfs"` | Rootfs datastore ID. |
| `disk_size_gb` | `number` | `32` | Rootfs size in GiB. |
| `ipv4_address` | `string` | `"dhcp"` | Static IPv4 CIDR or `"dhcp"`. |
| `ipv4_gateway` | `string` | `null` | IPv4 gateway (must be `null` for `"dhcp"`). |
| `device_passthroughs` | `list(object)` | `[]` | Host device nodes passed into LXC (`mode` defaults to `"0660"`). |
| `mount_points` | `list(object)` | `[]` | Host bind mounts or storage volumes. |

## Outputs

| Name | Description |
| :--- | :--- |
| `id` | Full Proxmox container resource ID. |
| `vm_id` | Numeric Proxmox container ID. |
| `node_name` | Proxmox node hosting the container. |
| `hostname` | Container hostname. |
| `ipv4_address` | Primary IPv4 address assigned to `eth0`. |
| `ipv4_addresses` | Map of interface names to IPv4 addresses. |
| `mac_address` | MAC address of `eth0`. |
