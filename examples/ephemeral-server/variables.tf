variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
  default     = "dummy-token-for-validation"
}

variable "server_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "example-ephemeral"
}

variable "location" {
  description = "Hetzner location"
  type        = string
  default     = "fsn1"
}
