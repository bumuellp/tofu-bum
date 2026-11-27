# tofu-bum

Production-grade, reusable [OpenTofu](https://opentofu.org) and Terraform modules for cloud infrastructure, ephemeral compute, persistent storage, and network security.

---

## 📦 Available Modules

| Module | Description | Inputs / Outputs |
| :--- | :--- | :--- |
| **[`modules/hcloud-volume`](modules/hcloud-volume/)** | Persistent Hetzner Cloud block volume with delete protection and predictable device paths. | [Docs](modules/hcloud-volume/) |
| **[`modules/hcloud-firewall`](modules/hcloud-firewall/)** | Dynamic Hetzner Cloud firewall rule generator with protocol and port filtering. | [Docs](modules/hcloud-firewall/) |
| **[`modules/hcloud-ephemeral-server`](modules/hcloud-ephemeral-server/)** | Ephemeral server compute provisioner with automatic volume attachment and cloud-init injection. | [Docs](modules/hcloud-ephemeral-server/) |
| **[`modules/proxmox-k3s-lxc`](modules/proxmox-k3s-lxc/)** | Privileged Proxmox VE LXC provisioner for K3s with native GPU `device_passthrough` and host bind mounts. | [Docs](modules/proxmox-k3s-lxc/) |

---

## 🚀 Quick Start Example

Compose an ephemeral server with persistent volume and firewall rules:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# 1. Persistent Storage (Retained across server rebuilds)
module "volume" {
  source   = "git::https://github.com/bumuellp/tofu-bum.git//modules/hcloud-volume?ref=v1.0.0"
  name     = "app-data"
  size     = 10
  location = "fsn1"
}

# 2. Network Firewall
module "firewall" {
  source = "git::https://github.com/bumuellp/tofu-bum.git//modules/hcloud-firewall?ref=v1.0.0"
  name   = "app-firewall"
  rules = [
    {
      direction   = "in"
      protocol    = "tcp"
      port        = "80"
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = "HTTP"
    },
    {
      direction   = "in"
      protocol    = "tcp"
      port        = "443"
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = "HTTPS"
    }
  ]
}

# 3. Ephemeral Compute
module "server" {
  source       = "git::https://github.com/bumuellp/tofu-bum.git//modules/hcloud-ephemeral-server?ref=v1.0.0"
  name         = "app-worker"
  server_type  = "cpx21"
  image        = "docker-ce"
  location     = "fsn1"
  firewall_ids = [module.firewall.id]
  volume_id    = module.volume.id
  user_data    = file("${path.module}/cloud-init.yaml")
}
```

---

## 🗄️ Remote Backend & State Locking

For production use, see [`templates/backend-s3.tf.example`](templates/backend-s3.tf.example) for a standardized, partial S3 backend configuration with native OpenTofu state locking (`use_lockfile = true`) tested against Hetzner Object Storage.

---

## 🛡️ Quality Gates & Testing

* **Formatting & Linting**: Enforces `tofu fmt -check` and Trivy IaC configuration scanning via [`cabumtain-hook`](.pre-commit-config.yaml).
* **CI Validation**: Automated PR verification executed via [`bumuellp/lights-camera-bum-action`](.github/workflows/ci.yml).
* **Module Validate & Test**: [`.github/workflows/module-test.yml`](.github/workflows/module-test.yml) calls `bumuellp/lights-camera-bum-action/.github/workflows/tofu-test.yml` to run `tofu init -backend=false`, `tofu validate`, and `tofu test` (when `*.tftest.hcl` or `*.tftest.json` files exist) across every `modules/*` directory. `tofu validate` and `tofu test` are intentionally omitted from local `pre-commit` hooks because they require `tofu init` (downloading provider binaries over the network), which slows down commits and breaks offline workflows.

---

## ⚖️ License

Licensed under the [MIT License](LICENSE) © 2026 Patrick Bumüller.
