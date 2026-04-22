resource "aws_lb_listener_rule" "rule" {
  listener_arn = var.listener_arn
  priority     = var.priority
  region       = var.region
  tags         = var.tags

  dynamic "action" {
    for_each = var.action
    content {
      type             = action.value.type
      order            = action.value.order
      target_group_arn = action.value.target_group_arn

      dynamic "forward" {
        for_each = action.value.forward != null ? [action.value.forward] : []
        content {
          dynamic "target_group" {
            for_each = forward.value.target_group
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }

          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }

      dynamic "redirect" {
        for_each = action.value.redirect != null ? [action.value.redirect] : []
        content {
          status_code = redirect.value.status_code
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
        }
      }

      dynamic "fixed_response" {
        for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }

      dynamic "authenticate_cognito" {
        for_each = action.value.authenticate_cognito != null ? [action.value.authenticate_cognito] : []
        content {
          user_pool_arn                       = authenticate_cognito.value.user_pool_arn
          user_pool_client_id                 = authenticate_cognito.value.user_pool_client_id
          user_pool_domain                    = authenticate_cognito.value.user_pool_domain
          authentication_request_extra_params = authenticate_cognito.value.authentication_request_extra_params
          on_unauthenticated_request          = authenticate_cognito.value.on_unauthenticated_request
          scope                               = authenticate_cognito.value.scope
          session_cookie_name                 = authenticate_cognito.value.session_cookie_name
          session_timeout                     = authenticate_cognito.value.session_timeout
        }
      }

      dynamic "authenticate_oidc" {
        for_each = action.value.authenticate_oidc != null ? [action.value.authenticate_oidc] : []
        content {
          authorization_endpoint              = authenticate_oidc.value.authorization_endpoint
          client_id                           = authenticate_oidc.value.client_id
          client_secret                       = authenticate_oidc.value.client_secret # pragma: allowlist secret
          issuer                              = authenticate_oidc.value.issuer
          token_endpoint                      = authenticate_oidc.value.token_endpoint # pragma: allowlist secret
          user_info_endpoint                  = authenticate_oidc.value.user_info_endpoint
          authentication_request_extra_params = authenticate_oidc.value.authentication_request_extra_params
          on_unauthenticated_request          = authenticate_oidc.value.on_unauthenticated_request
          scope                               = authenticate_oidc.value.scope
          session_cookie_name                 = authenticate_oidc.value.session_cookie_name
          session_timeout                     = authenticate_oidc.value.session_timeout
        }
      }

      dynamic "jwt_validation" {
        for_each = action.value.jwt_validation != null ? [action.value.jwt_validation] : []
        content {
          issuer        = jwt_validation.value.issuer
          jwks_endpoint = jwt_validation.value.jwks_endpoint

          dynamic "additional_claim" {
            for_each = jwt_validation.value.additional_claim != null ? jwt_validation.value.additional_claim : []
            content {
              format = additional_claim.value.format
              name   = additional_claim.value.name
              values = additional_claim.value.values
            }
          }
        }
      }
    }
  }

  dynamic "condition" {
    for_each = var.condition
    content {
      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values       = host_header.value.values
          regex_values = host_header.value.regex_values
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
          regex_values     = http_header.value.regex_values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.http_request_method != null ? [condition.value.http_request_method] : []
        content {
          values = http_request_method.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values       = path_pattern.value.values
          regex_values = path_pattern.value.regex_values
        }
      }

      dynamic "query_string" {
        for_each = condition.value.query_string != null ? condition.value.query_string : []
        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.source_ip != null ? [condition.value.source_ip] : []
        content {
          values = source_ip.value.values
        }
      }
    }
  }

  dynamic "transform" {
    for_each = var.transform != null ? [var.transform] : []
    content {
      type = transform.value.type

      dynamic "host_header_rewrite_config" {
        for_each = transform.value.host_header_rewrite_config != null ? [transform.value.host_header_rewrite_config] : []
        content {
          dynamic "rewrite" {
            for_each = host_header_rewrite_config.value.rewrite != null ? [host_header_rewrite_config.value.rewrite] : []
            content {
              regex   = rewrite.value.regex
              replace = rewrite.value.replace
            }
          }
        }
      }

      dynamic "url_rewrite_config" {
        for_each = transform.value.url_rewrite_config != null ? [transform.value.url_rewrite_config] : []
        content {
          dynamic "rewrite" {
            for_each = url_rewrite_config.value.rewrite != null ? [url_rewrite_config.value.rewrite] : []
            content {
              regex   = rewrite.value.regex
              replace = rewrite.value.replace
            }
          }
        }
      }
    }
  }
}
