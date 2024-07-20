# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = var.name_ecs
}

data "template_file" "ecs_app" {
  template = file("./modules/ecs/templates/ecs/ecs_app.json.tpl")

  vars = {
    name_app       = var.name_ecs
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    db_host        = var.db_host
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_ecs}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.ecs_app.rendered
}

resource "aws_ecs_service" "main" {
  name            = "${var.name_ecs}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.sg_ecs_tasks
    subnets          = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.name_ecs
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}