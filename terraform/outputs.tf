output "lb_hostname" {
  value = module.ecs_app.alb_hostname
}

# Define o output para o endpoint do RDS
output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
