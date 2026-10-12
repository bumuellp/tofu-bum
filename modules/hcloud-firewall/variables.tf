variable "name" {
  description = "Name of the Hetzner firewall"
  type        = string
}

variable "rules" {
  description = "List of firewall rule definitions"
  type = list(object({
    direction       = string
    protocol        = string
    port            = optional(string)
    source_ips      = optional(list(string), [])
    destination_ips = optional(list(string), [])
    description     = optional(string)
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the firewall"
  type        = map(string)
  default     = {}
}
