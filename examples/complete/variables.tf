// Resource naming variables

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
  default     = "launch"
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
  default     = "lbrule"
}

variable "class_env" {
  description = "Environment class for resource naming."
  type        = number
  default     = 0
}

variable "instance_env" {
  description = "Environment instance number for resource naming."
  type        = number
  default     = 0
}

variable "instance_resource" {
  description = "Resource instance number for resource naming."
  type        = number
  default     = 0
}

variable "resource_names_map" {
  description = "Map of resource names to create via the resource naming module."
  type = map(object({
    name       = string
    max_length = number
  }))
  default = {
    alb = {
      name       = "alb"
      max_length = 32
    }
    tg = {
      name       = "tg"
      max_length = 32
    }
  }
}

// Module passthrough variables

variable "listener_arn" {
  description = "The ARN of the listener to which to attach the rule. If not specified, the listener created by this example is used."
  type        = string
  default     = null
}

variable "priority" {
  description = "The priority for the rule between 1 and 50000."
  type        = number
  default     = null
}

variable "action" {
  description = "List of action blocks for the listener rule. If not specified, defaults to forwarding to the target group created by this example."
  type        = any
  default     = null
}

variable "condition" {
  description = "List of condition blocks for the listener rule."
  type = list(object({
    host_header = optional(object({
      values       = optional(list(string))
      regex_values = optional(list(string))
    }))
    http_header = optional(object({
      http_header_name = string
      values           = optional(list(string))
      regex_values     = optional(list(string))
    }))
    http_request_method = optional(object({
      values = list(string)
    }))
    path_pattern = optional(object({
      values       = optional(list(string))
      regex_values = optional(list(string))
    }))
    query_string = optional(list(object({
      key   = optional(string)
      value = string
    })))
    source_ip = optional(object({
      values = list(string)
    }))
  }))
}

variable "transform" {
  description = "Configuration block that defines the transform to apply to requests matching this rule."
  type        = any
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region where the listener rule will be managed. Defaults to the region set in the provider configuration."
  type        = string
  default     = null
}
