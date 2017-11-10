variable "domain" {
  description = "The top level domain the service should live under - e.g. mmgapi.net"
}

variable "name" {
  description = "The leftmost part of the DNS name (minus the environment)"
}

variable "env" {
  description = "The name of the environment (included at the front of the DNS name with a hyphen if not live)"
}

variable "priority" {
  description = "ALB listener rule priority"
}

variable "target_group_arn" {
  description = "The ARN of the target group to send traffic to"
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener to add the rule to."
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB to point the DNS at"
}

variable "ttl" {
  description = "Time to live"
  default = "60"
}
