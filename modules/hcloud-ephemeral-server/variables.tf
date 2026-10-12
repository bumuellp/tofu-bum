variable "name" {
  description = "Name of the Hetzner server"
  type        = string
}

variable "server_type" {
  description = "Hetzner Cloud server type (e.g. cpx21, cx22, cax11)"
  type        = string
  default     = "cpx21"
}

variable "image" {
  description = "Operating system image or app image (e.g. docker-ce, ubuntu-24.04)"
  type        = string
  default     = "docker-ce"
}

variable "location" {
  description = "Hetzner Cloud location (e.g. fsn1, nbg1, hel1)"
  type        = string
  default     = "fsn1"
}

variable "user_data" {
  description = "Cloud-Init user data script"
  type        = string
  default     = ""
}

variable "firewall_ids" {
  description = "List of firewall IDs to attach to the server"
  type        = list(string)
  default     = []
}

variable "ssh_keys" {
  description = "List of SSH key IDs or names to inject into the server"
  type        = list(string)
  default     = []
}

variable "volume_id" {
  description = "Optional persistent volume ID to attach to this server"
  type        = string
  default     = null
}

variable "automount_volume" {
  description = "Whether Hetzner automount should be enabled for attached volume"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the server"
  type        = map(string)
  default     = {}
}
