variable "name" {
  description = "Name of the persistent Hetzner volume"
  type        = string
}

variable "size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 10
}

variable "location" {
  description = "Hetzner Cloud location (e.g. fsn1, nbg1, hel1)"
  type        = string
  default     = "fsn1"
}

variable "format" {
  description = "Initial format type for the volume (ext4 or xfs)"
  type        = string
  default     = "ext4"
}

variable "delete_protection" {
  description = "Enable delete protection on the Hetzner volume to guard against accidental destruction"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to the volume"
  type        = map(string)
  default     = {}
}
