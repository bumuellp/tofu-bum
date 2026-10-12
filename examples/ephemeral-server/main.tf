module "volume" {
  source   = "../../modules/hcloud-volume"
  name     = "${var.server_name}-data"
  size     = 10
  location = var.location
}

module "firewall" {
  source = "../../modules/hcloud-firewall"
  name   = "${var.server_name}-fw"
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

module "server" {
  source       = "../../modules/hcloud-ephemeral-server"
  name         = var.server_name
  server_type  = "cpx21"
  image        = "docker-ce"
  location     = var.location
  firewall_ids = [module.firewall.id]
  volume_id    = module.volume.id
  user_data    = "#!/bin/bash\necho 'Server initialized' > /var/log/init.log\n"
}
