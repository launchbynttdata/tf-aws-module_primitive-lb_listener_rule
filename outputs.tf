output "id" {
  description = "The ID of the listener rule (same as the ARN)."
  value       = aws_lb_listener_rule.rule.id
}

output "arn" {
  description = "The ARN of the listener rule."
  value       = aws_lb_listener_rule.rule.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_lb_listener_rule.rule.tags_all
}
