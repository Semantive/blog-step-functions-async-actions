data "aws_region" "current" {}

# lambda_async_invoke

resource "aws_iam_role" "lambda_async_invoke" {
  name = "${terraform.workspace}-lambda-async-invoke"
  assume_role_policy = "${file("${path.module}/assume_role/lambda.json")}"
}

resource "aws_iam_role_policy" "lambda_async_invoke_logs" {
  role = "${aws_iam_role.lambda_async_invoke.id}"
  policy = "${file("${path.module}/policy/lambda_logs.json")}"
}

resource "aws_iam_role_policy" "lambda_async_invoke_execution" {
  role = "${aws_iam_role.lambda_async_invoke.id}"
  policy = "${file("${path.module}/policy/lambda_async_invoke_execution.json")}"
}

# lambda_acitivity_response

resource "aws_iam_role" "lambda_activity_response" {
  name = "${terraform.workspace}-lambda-activity-response"
  assume_role_policy = "${file("${path.module}/assume_role/lambda.json")}"
}

resource "aws_iam_role_policy" "lambda_activity_response_logs" {
  role = "${aws_iam_role.lambda_activity_response.id}"
  policy = "${file("${path.module}/policy/lambda_logs.json")}"
}

resource "aws_iam_role_policy" "lambda_activity_response" {
  role = "${aws_iam_role.lambda_activity_response.id}"
  policy = "${file("${path.module}/policy/lambda_activity_response.json")}"
}

# states_execution

resource "aws_iam_role" "states_execution" {
  name = "${terraform.workspace}-states-execution"
  assume_role_policy = "${data.template_file.assume_policy_states.rendered}"
}

data "template_file" "assume_policy_states" {
  template = "${file("${path.module}/assume_role/states.json")}"
  vars {
    aws_region = "${data.aws_region.current.id}"
  }
}

resource "aws_iam_role_policy" "states_execution" {
  role = "${aws_iam_role.states_execution.id}"
  policy = "${file("${path.module}/policy/states_execution.json")}"
}

# outputs

output "lambda_async_invoke_role_arn" {
  value = "${aws_iam_role.lambda_async_invoke.arn}"
}

output "lambda_activity_response_role_arn" {
  value = "${aws_iam_role.lambda_activity_response.arn}"
}

output "states_execution_role_arn" {
  value = "${aws_iam_role.states_execution.arn}"
}
