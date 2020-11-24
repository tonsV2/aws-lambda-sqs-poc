output "api_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}

output "sqs_url" {
  value = aws_sqs_queue.sqs.id
}
/*
output "lambda-env" {
  value = aws_lambda_function.event.environment
}
*/
