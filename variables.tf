variable "region" {
  default     = ""
  description = "The region where the EC2 instances are located. This is an optional parameter. If no region variable is specified in the calling module, the aws_region data source is used to auto-determine the current region."
}

variable "ec2_instance_ids" {
  description = "A list of EC2 instance IDs to start and stop"
  type        = "list"
}

# trigger every weekday at 7AM UTC
variable "cron_expr_start" {
  default = "cron(0 7 ? * 2-6 *)"
}

# trigger every weekday at 7PM UTC
variable "cron_expr_stop" {
  default = "cron(0 19 ? * 2-6 *)"
}
