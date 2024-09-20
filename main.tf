# Create an AWS Lambda function to trigger task actions
resource "aws_lambda_function" "trigger_task" {
  function_name = "trigger_task"
  runtime = "python3.9"
  role = aws_iam_role.lambda_role.arn
  handler = "lambda_function.handler"
  code {
    zip_file = base64encode(file("lambda_function.py"))
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM policy for the Lambda role
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecs:RunTask",
          "ecs:StopTask"
        ],
        "Resource": [
          aws_ecs_cluster.example.arn,
          aws_ecs_task_definition.example.arn
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function code (lambda_function.py)
def handler(event, context):
  import boto3

  ecs_client = boto3.client('ecs')

  # Start a task
  response = ecs_client.run_task(
      cluster=aws_ecs_cluster.example.name,
      taskDefinition=aws_ecs_task_definition.example.arn
  )
  task_arn = response['tasks'][0]['taskArn']
  print(f"Started task: {task_arn}")

  # Stop the task after a delay (adjust as needed)
  import time
  time.sleep(60)
  ecs_client.stop_task(
      cluster=aws_ecs_cluster.example.name,
      task=task_arn
  )
  print(f"Stopped task: {task_arn}")
