variable "env" {
  description = "The name of the environment (included at the front of the DNS name with a hyphen if not live)"
}

variable "component_name" {
  type        = "string"
  description = "The name of the component - used by default for the DNS entry (with the -service suffix removed), as well as to give the target group a meaningful name"
  default     = ""
}

variable "dns_name" {
  type        = "string"
  description = "The first part of the DNS name without the environment (defaults to component_name with -service suffix removed)"
  default     = ""
}

variable "dns_domain" {
  description = "The top level domain the service should live under - e.g. mmgapi.net"
}

variable "ttl" {
  description = "Time to live"
  default     = "60"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB to point the DNS at"
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener to add the rule to."
}

variable "priority" {
  description = "ALB listener rule priority"
}

variable "vpc_id" {
  description = "The identifier of the VPC in which to create the target group."
  type        = "string"
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds."
  type        = "string"
  default     = "10"
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  type        = "string"
  default     = "5"
}

variable "health_check_path" {
  description = "The destination for the health check request."
  type        = "string"
  default     = "/internal/healthcheck"
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check."
  type        = "string"
  default     = "4"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
  type        = "string"
  default     = "2"
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy."
  type        = "string"
  default     = "2"
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
  type        = "string"
  default     = "200-299"
}
