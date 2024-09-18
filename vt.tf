resource "aws_ecs_cluster" "example" {
  name = "example"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  container_definitions    = jsonencode([
    {
      name      = "example"
      image     = "amazonlinux"
      cpu       = 256
      memory    = 512
      essential = true
      command   = ["echo", "Hello, World!"]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.example.id]
    security_groups = [aws_security_group.example.id]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1"
}

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "null_resource" "run_task" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task --cluster ${aws_ecs_cluster.example.name} --task-definition ${aws_ecs_task_definition.example.family} --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[${aws_subnet.example.id}],securityGroups=[${aws_security_group.example.id}],assignPublicIp=ENABLED}"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "wait_for_task_completion" {
  depends_on = [null_resource.run_task]

  provisioner "local-exec" {
    command = <<EOT
      aws ecs wait tasks-stopped --cluster ${aws_ecs_cluster.example.name} --tasks $(aws ecs list-tasks --cluster ${aws_ecs_cluster.example.name} --desired-status STOPPED --query 'taskArns[0]' --output text)
    EOT
  }
}
