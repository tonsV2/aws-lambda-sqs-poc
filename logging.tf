resource "aws_cloudwatch_log_group" "event" {
  name = "/aws/lambda/${aws_lambda_function.event.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/lambda/${aws_lambda_function.example.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "example" {
  role = aws_iam_role.example.name
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_iam_role_policy_attachment" "event" {
  role = aws_iam_role.event.name
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_iam_policy" "logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = data.aws_iam_policy_document.logging.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
