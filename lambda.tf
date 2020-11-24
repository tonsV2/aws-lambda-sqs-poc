resource "aws_lambda_function" "example" {
  function_name = "ServerlessExampleBook"

  s3_bucket = "mn-lambda"
  s3_key = "mn/v1.0.0/lambda-1.0.0-all.jar"

  handler = "dk.fitfit.handler.BookRequestHandler"
  runtime = "java11"

  memory_size = 512

  role = aws_iam_role.example.arn
/*
  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    // TODO: Should be public?
    subnet_ids = [for subnet in aws_subnet.private: subnet.id]
  }

  environment {
    variables = {
      MICRONAUT_ENVIRONMENTS = "aws"
      JDBC_DATABASE_URL = "jdbc:postgresql://${aws_db_instance.rds.address}:${aws_db_instance.rds.port}/${aws_db_instance.rds.name}"
      DATABASE_USERNAME = aws_db_instance.rds.username
      DATABASE_PASSWORD = aws_db_instance.rds.password
    }
  }
*/
}

resource "aws_lambda_function" "event" {
  function_name = "ServerlessExampleEvent"

  timeout = 30

  s3_bucket = "mn-lambda"
  //s3_key = "mn/v1.0.0/lambda-1.0.0-all.jar"
  s3_key = "nodejs/v1.0.0/main.zip"

  //handler = "dk.fitfit.handler.EventRequestHandler"
  handler = "main.handler"
  //runtime = "java11"
  runtime = "nodejs12.x"

  memory_size = 512

  role = aws_iam_role.event.arn

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids = [for subnet in aws_subnet.private: subnet.id]
  }

  environment {
    variables = {
      MICRONAUT_ENVIRONMENTS = "aws"
      JDBC_DATABASE_URL = "jdbc:postgresql://${aws_db_instance.rds.address}:${aws_db_instance.rds.port}/${aws_db_instance.rds.name}"
      DATABASE_USERNAME = aws_db_instance.rds.username
      DATABASE_PASSWORD = aws_db_instance.rds.password
    }
  }
}

# IAM role which dictates what other AWS services the Lambda function may access.
resource "aws_iam_role" "example" {
  name = "serverless_example_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "event" {
  name = "serverless_example_lambda_event"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

// Error: error creating Lambda Function: InvalidParameterValueException: The provided execution role does not have permissions to call CreateNetworkInterface on EC2
// https://stackoverflow.com/a/64044160/672009
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole-event" {
  role = aws_iam_role.event.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
/*
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole-example" {
  role = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
*/
resource "aws_iam_role_policy_attachment" "sqs" {
  role = aws_iam_role.event.name
  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_iam_policy" "sqs" {
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    effect = "Allow"
    resources = [aws_sqs_queue.sqs.arn]

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
  }
}
