variable "vm_config" {
  type = list(object({
    name = string
    instance_type = string
    tags = optional(map(string), {})
  }))
}
