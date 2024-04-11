provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

// Use heredoc syntax to embed the JSON template directly
resource "aws_ecs_task_definition" "my_task_definition" {
  family                = "my-task-family"
  container_definitions = <<-EOT
    [
      {
        "name": "my-container",
        "image": "654654184219.dkr.ecr.us-east-1.amazonaws.com/capstone-ecr:latest",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ]
      }
    ]
  EOT
}

resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"
}

resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0faf0518a55c4b709"]
  subnets            = ["subnet-0f27e2226fb9a067f", "subnet-0217d595b666796ca", "subnet-00a6b190443f3b2f37"]
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = "vpc-0f553d63e62258833"
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "ecs_attachments" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = "i-0c1c37f979c5f2e5d" // Replace with your EC2 instance ID
}