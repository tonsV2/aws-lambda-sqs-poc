resource "aws_sqs_queue" "sqs" {
  name = "lambda-feeding-queue"
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.sqs.arn
  function_name = aws_lambda_function.event.arn
  enabled = true
  batch_size = 1
}
