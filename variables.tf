variable "listener_arn" {
  description = "The ARN of the listener to which to attach the rule."
  type        = string
}

variable "priority" {
  description = "The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule."
  type        = number
  default     = null

  validation {
    condition     = var.priority == null ? true : (var.priority >= 1 && var.priority <= 50000)
    error_message = "Priority must be between 1 and 50000."
  }
}

variable "action" {
  description = <<-EOT
    List of action blocks for the listener rule. Each action block supports the following:
      type             = The type of routing action. Valid values: forward, redirect, fixed-response, authenticate-cognito, authenticate-oidc, jwt-validation.
      order            = Order for the action. Valid values: 1 to 50000.
      target_group_arn = ARN of the Target Group to route traffic to. Only for type = forward with a single target group. Cannot be specified with forward.
      forward          = Configuration block for distributing requests among one or more target groups.
      redirect         = Information for creating a redirect action.
      fixed_response   = Information for creating a custom HTTP response.
      authenticate_cognito = Information for Cognito authentication.
      authenticate_oidc    = Information for OIDC authentication.
      jwt_validation       = Information for JWT validation.
  EOT
  type = list(object({
    type             = string
    order            = optional(number)
    target_group_arn = optional(string)
    forward = optional(object({
      target_group = list(object({
        arn    = string
        weight = optional(number)
      }))
      stickiness = optional(object({
        enabled  = bool
        duration = optional(number)
      }))
    }))
    redirect = optional(object({
      status_code = string
      host        = optional(string)
      path        = optional(string)
      port        = optional(string)
      protocol    = optional(string)
      query       = optional(string)
    }))
    fixed_response = optional(object({
      content_type = string
      message_body = optional(string)
      status_code  = optional(string)
    }))
    authenticate_cognito = optional(object({
      user_pool_arn                       = string
      user_pool_client_id                 = string
      user_pool_domain                    = string
      authentication_request_extra_params = optional(map(string))
      on_unauthenticated_request          = optional(string)
      scope                               = optional(string)
      session_cookie_name                 = optional(string)
      session_timeout                     = optional(number)
    }))
    authenticate_oidc = optional(object({
      authorization_endpoint              = string
      client_id                           = string
      client_secret                       = string # pragma: allowlist secret
      issuer                              = string
      token_endpoint                      = string # pragma: allowlist secret
      user_info_endpoint                  = string
      authentication_request_extra_params = optional(map(string))
      on_unauthenticated_request          = optional(string)
      scope                               = optional(string)
      session_cookie_name                 = optional(string)
      session_timeout                     = optional(number)
    }))
    jwt_validation = optional(object({
      issuer        = string
      jwks_endpoint = string
      additional_claim = optional(list(object({
        format = string
        name   = string
        values = list(string)
      })))
    }))
  }))

  validation {
    condition = alltrue([
      for a in var.action : contains(
        ["forward", "redirect", "fixed-response", "authenticate-cognito", "authenticate-oidc", "jwt-validation"],
        a.type
      )
    ])
    error_message = "Each action.type must be one of: forward, redirect, fixed-response, authenticate-cognito, authenticate-oidc, jwt-validation."
  }

  validation {
    condition = alltrue([
      for a in var.action : a.redirect == null ? true : contains(["HTTP_301", "HTTP_302"], a.redirect.status_code)
    ])
    error_message = "Each action.redirect.status_code must be HTTP_301 or HTTP_302."
  }
}

variable "condition" {
  description = <<-EOT
    List of condition blocks for the listener rule. Each condition block must contain exactly one of:
      host_header         = Host header patterns to match (values or regex_values).
      http_header         = Single HTTP header to match. To match multiple distinct headers, use multiple condition blocks.
      http_request_method = HTTP methods to match.
      path_pattern        = Path patterns to match (values or regex_values).
      query_string        = List of query string key/value pairs to match (repeatable within a single condition).
      source_ip           = Source IP CIDR notations to match.
  EOT
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
  description = <<-EOT
    Configuration block that defines the transform to apply to requests matching this rule.
      type                       = Type of transform. Valid values: host-header-rewrite, url-rewrite.
      host_header_rewrite_config = Configuration block for host header rewrite.
      url_rewrite_config         = Configuration block for URL rewrite.
  EOT
  type = object({
    type = string
    host_header_rewrite_config = optional(object({
      rewrite = optional(object({
        regex   = string
        replace = string
      }))
    }))
    url_rewrite_config = optional(object({
      rewrite = optional(object({
        regex   = string
        replace = string
      }))
    }))
  })
  default = null

  validation {
    condition     = var.transform == null ? true : contains(["host-header-rewrite", "url-rewrite"], var.transform.type)
    error_message = "transform.type must be host-header-rewrite or url-rewrite."
  }
}

variable "tags" {
  description = "Map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region where this resource will be managed. Defaults to the region set in the provider configuration."
  type        = string
  default     = null
}
