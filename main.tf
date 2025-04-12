resource "aws_ecs_cluster" "main" {
  name = "flask-cluster"
}

resource "aws_ecs_task_definition" "flask_task" {
  family                   = "flask-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "lach",
      image = "255945442255.dkr.ecr.us-east-1.amazonaws.com/lachecr:latest",
      portMappings = [
        {
          containerPort = 5050,
          hostPort      = 5050,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "flask_service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [data.aws_subnets.filtered_subnets]
    assign_public_ip = true
    security_groups  = [data.aws_security_group.ecs_sg]
  }
}

# Fetch the VPC ID by name
data "aws_vpcs" "filtered_vpcs" {
  filter {
    name   = "tag:Name"
    values = ["LACH*"]
  }
}
output "vpcs" {value = data.aws_vpcs.filtered_vpcs.ids}

data aws_security_group "ecs_sg" {
  filter {
    name = "vpc-id"
    values = data.aws_vpcs.filtered_vpcs.ids
  }
}

# Fetch subnets for the filtered VPC
#===================================
data "aws_subnets" "filtered_subnets" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.filtered_vpcs.ids
  }
}
output "subnet_ids" {value = data.aws_subnets.filtered_subnets.ids}

# Fetch public subnets for the filtered VPC
#==========================================
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.filtered_vpcs.ids
  }
  tags = {
    Name = "LACH*"
  }
}
output "public_subnet_ids" {value = data.aws_subnets.public.ids}
# Fetch one public subnets
output "public_subnet_id1" {value = data.aws_subnets.public.ids[0]}
output "public_subnet_id2" {value = data.aws_subnets.public.ids[1]}
