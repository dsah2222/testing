
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



terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "path/to/my/key"
    region         = "us-west-2"
    dynamodb_table = "my-terraform-lock-table"  # Optional for state locking
    encrypt        = true
  }
}







resource "null_resource" "run_task" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task --cluster example-cluster --task-definition ${aws_ecs_task_definition.example.family} --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[${aws_subnet.example.id}],securityGroups=[${aws_security_group.example.id}],assignPublicIp=ENABLED}"
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
      aws ecs wait tasks-stopped --cluster example-cluster --tasks $(aws ecs list-tasks --cluster example-cluster --desired-status STOPPED --query 'taskArns[0]' --output text)
    EOT
  }
}


resource "null_resource" "run_task" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task --cluster example-cluster --task-definition ${aws_ecs_task_definition.example.family} --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}"
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
      aws ecs wait tasks-stopped --cluster example-cluster --tasks $(aws ecs list-tasks --cluster example-cluster --desired-status STOPPED --query 'taskArns[0]' --output text)
    EOT
  }
}


resource"aws_ecs_task" "task" {
cluster = aws_ecs_cluster.tooling-mang-sandbox-cluster
task_definition = aws_ecs_task_definition.ppure-tmgt.arn
depends_on = [aws_ecs_service.ppure-tmgt-service]
}

resource"aws_ecs_task" "stopped_task" {
cluster = aws_ecs_cluster.tooling-mang-sandbox-cluster
task_definition = aws_ecs_task_definition.ppure-tmgt.arn
depends_on = [aws_ecs_task.ppure-tmgt]
desired_status = "STOPPED"
}
