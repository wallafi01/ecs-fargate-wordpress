variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}


variable "vpc_name" {
  description = "The name of the VPC."
  default = "tst"
}

variable "vpc_cidr" {
  description = "CIDR blocks for the VPCs"
  type        = string
  
}

variable "azs" {
  description = "A list of availability zones in the region."
  type        = list(string)  
}

variable "private_subnets" {
  description = "Private subnets for each environment"
  type        = list(string)

}

variable "public_subnets" {
  description = "Public subnets for each environment"
  type        = list(string)

} 

variable "name_ecs" {
  type = string
}

variable "name_rds" {
  type = string
}

variable "fargate_cpu" {
   type = number 
}
variable "fargate_cpu" {
    type = number
}

variable "app_port" {
    type = number
}