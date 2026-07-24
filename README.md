# tf-aws-module_primitive-lb_listener_rule

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

> **AWS Provider v6.22.0+ Required** — This module requires `hashicorp/aws` provider **>= 6.22.0, < 7.0.0**. It is **not compatible** with provider v5 or earlier, nor with 6.x releases prior to 6.22.0. This is the first primitive module in our fleet to drop v5 support. The lower bound is driven by features this module hard-codes into its resource schema: `transform` (host-header-rewrite, url-rewrite) and `regex_values` on conditions landed in v6.19.0, and `jwt_validation` action support landed in v6.22.0. If your root module or other primitives still pin to `~> 5.x` or an early 6.x release, you will need to upgrade before consuming this module.

This module manages an AWS Application Load Balancer (ALB) Listener Rule (`aws_lb_listener_rule`). It supports all action types (forward, redirect, fixed-response, authenticate-cognito, authenticate-oidc, jwt-validation), all condition types (host header, HTTP header, HTTP request method, path pattern, query string, source IP), and the transform feature (host header rewrite, URL rewrite) introduced in AWS provider 6.0.

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline.

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## Usage

### Prerequisites

- [asdf](https://github.com/asdf-vm/asdf) used for tool version management
- [make](https://www.gnu.org/software/make/) used for automating various functions of the repo
- [repo](https://android.googlesource.com/tools/repo) used to pull in all components to create the full repo template

### Repo Setup

Run the following command to prep repo and enable all `Makefile` commands to run:

```shell
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

### Running Tests

Ensure AWS credentials are configured, then run:

```shell
make check
```

`make check` runs `terraform commands` to `lint`, `validate` and `plan` terraform code, `conftests` for policy checks, `terratest` integration tests, and `opa` tests.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.22.0, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | List of action blocks for the listener rule. Each action block supports the following:<br/>  type             = The type of routing action. Valid values: forward, redirect, fixed-response, authenticate-cognito, authenticate-oidc, jwt-validation.<br/>  order            = Order for the action. Valid values: 1 to 50000.<br/>  target\_group\_arn = ARN of the Target Group to route traffic to. Only for type = forward with a single target group. Cannot be specified with forward.<br/>  forward          = Configuration block for distributing requests among one or more target groups.<br/>  redirect         = Information for creating a redirect action.<br/>  fixed\_response   = Information for creating a custom HTTP response.<br/>  authenticate\_cognito = Information for Cognito authentication.<br/>  authenticate\_oidc    = Information for OIDC authentication.<br/>  jwt\_validation       = Information for JWT validation. | <pre>list(object({<br/>    type             = string<br/>    order            = optional(number)<br/>    target_group_arn = optional(string)<br/>    forward = optional(object({<br/>      target_group = list(object({<br/>        arn    = string<br/>        weight = optional(number)<br/>      }))<br/>      stickiness = optional(object({<br/>        enabled  = bool<br/>        duration = optional(number)<br/>      }))<br/>    }))<br/>    redirect = optional(object({<br/>      status_code = string<br/>      host        = optional(string)<br/>      path        = optional(string)<br/>      port        = optional(string)<br/>      protocol    = optional(string)<br/>      query       = optional(string)<br/>    }))<br/>    fixed_response = optional(object({<br/>      content_type = string<br/>      message_body = optional(string)<br/>      status_code  = optional(string)<br/>    }))<br/>    authenticate_cognito = optional(object({<br/>      user_pool_arn                       = string<br/>      user_pool_client_id                 = string<br/>      user_pool_domain                    = string<br/>      authentication_request_extra_params = optional(map(string))<br/>      on_unauthenticated_request          = optional(string)<br/>      scope                               = optional(string)<br/>      session_cookie_name                 = optional(string)<br/>      session_timeout                     = optional(number)<br/>    }))<br/>    authenticate_oidc = optional(object({<br/>      authorization_endpoint              = string<br/>      client_id                           = string<br/>      client_secret                       = string # pragma: allowlist secret<br/>      issuer                              = string<br/>      token_endpoint                      = string # pragma: allowlist secret<br/>      user_info_endpoint                  = string<br/>      authentication_request_extra_params = optional(map(string))<br/>      on_unauthenticated_request          = optional(string)<br/>      scope                               = optional(string)<br/>      session_cookie_name                 = optional(string)<br/>      session_timeout                     = optional(number)<br/>    }))<br/>    jwt_validation = optional(object({<br/>      issuer        = string<br/>      jwks_endpoint = string<br/>      additional_claim = optional(list(object({<br/>        format = string<br/>        name   = string<br/>        values = list(string)<br/>      })))<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_condition"></a> [condition](#input\_condition) | List of condition blocks for the listener rule. Each condition block must contain exactly one of:<br/>  host\_header         = Host header patterns to match (values or regex\_values).<br/>  http\_header         = Single HTTP header to match. To match multiple distinct headers, use multiple condition blocks.<br/>  http\_request\_method = HTTP methods to match.<br/>  path\_pattern        = Path patterns to match (values or regex\_values).<br/>  query\_string        = List of query string key/value pairs to match (repeatable within a single condition).<br/>  source\_ip           = Source IP CIDR notations to match. | <pre>list(object({<br/>    host_header = optional(object({<br/>      values       = optional(list(string))<br/>      regex_values = optional(list(string))<br/>    }))<br/>    http_header = optional(object({<br/>      http_header_name = string<br/>      values           = optional(list(string))<br/>      regex_values     = optional(list(string))<br/>    }))<br/>    http_request_method = optional(object({<br/>      values = list(string)<br/>    }))<br/>    path_pattern = optional(object({<br/>      values       = optional(list(string))<br/>      regex_values = optional(list(string))<br/>    }))<br/>    query_string = optional(list(object({<br/>      key   = optional(string)<br/>      value = string<br/>    })))<br/>    source_ip = optional(object({<br/>      values = list(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | The ARN of the listener to which to attach the rule. | `string` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule. | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where this resource will be managed. Defaults to the region set in the provider configuration. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_transform"></a> [transform](#input\_transform) | Configuration block that defines the transform to apply to requests matching this rule.<br/>  type                       = Type of transform. Valid values: host-header-rewrite, url-rewrite.<br/>  host\_header\_rewrite\_config = Configuration block for host header rewrite.<br/>  url\_rewrite\_config         = Configuration block for URL rewrite. | <pre>object({<br/>    type = string<br/>    host_header_rewrite_config = optional(object({<br/>      rewrite = optional(object({<br/>        regex   = string<br/>        replace = string<br/>      }))<br/>    }))<br/>    url_rewrite_config = optional(object({<br/>      rewrite = optional(object({<br/>        regex   = string<br/>        replace = string<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the listener rule. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the listener rule (same as the ARN). |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags. |
<!-- END_TF_DOCS -->
