variable "subnet_ids" {
  type = list(any)
}

variable "environment" {
  type    = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_tasks_security_group_id" {
  type = string
}

variable "name_rds" {
  type = string
}