provider "aws" {}

# Deployment package

data "external" "deployment_package" {
  program = ["bash", "${path.module}/scripts/build_deployment_package.sh", "${path.module}"]
}

locals {
  lambda_filename = "${data.external.deployment_package.result["zip_path"]}"
  lambda_hash = "${data.external.deployment_package.result["source_hash"]}"
}

# IAM roles

module "iam" {
  source = "iam"
}

# Lambdas used in State Machines

resource "aws_lambda_function" "async_invoke" {
  function_name = "${terraform.workspace}-async-invoke"
  handler = "async_invoke.async_invoke_handler"
  role = "${module.iam.lambda_async_invoke_role_arn}"
  runtime = "python3.6"
  filename = "${local.lambda_filename}"
  source_code_hash = "${local.lambda_hash}"
  environment {
    variables {
      ASYNC_ACTION_ACTIVITY_ARN = "${aws_sfn_activity.wait_for_async_action.id}"
      NESTED_STATE_MACHINE_ARN = "${aws_sfn_state_machine.inner_state_machine.id}"
    }
  }
}

resource "aws_lambda_function" "send_success" {
  function_name = "${terraform.workspace}-send-success"
  handler = "send_success.handler"
  role = "${module.iam.lambda_activity_response_role_arn}"
  runtime = "python3.6"
  filename = "${local.lambda_filename}"
  source_code_hash = "${local.lambda_hash}"
}

resource "aws_lambda_function" "send_failure" {
  function_name = "${terraform.workspace}-send-failure"
  handler = "send_failure.handler"
  role = "${module.iam.lambda_activity_response_role_arn}"
  runtime = "python3.6"
  filename = "${local.lambda_filename}"
  source_code_hash = "${local.lambda_hash}"
}

# Outer State Machine

resource "aws_sfn_state_machine" "outer_state_machine" {
  name = "${terraform.workspace}-outer-state-machine"
  role_arn = "${module.iam.states_execution_role_arn}"
  definition = "${data.template_file.outer_state_machine_definition.rendered}"
}

resource "aws_sfn_activity" "wait_for_async_action" {
  name = "${terraform.workspace}-wait-for-async-action"
}

data "template_file" "outer_state_machine_definition" {
  template = "${file("state_machines/outer_state_machine.json")}"
  vars {
    async_invoke_lambda_arn = "${aws_lambda_function.async_invoke.arn}"
    wait_for_async_action_activity_arn = "${aws_sfn_activity.wait_for_async_action.id}"
  }
}

# Inner State Machine

resource "aws_sfn_state_machine" "inner_state_machine" {
  name = "${terraform.workspace}-inner-state-machine"
  role_arn = "${module.iam.states_execution_role_arn}"
  definition = "${data.template_file.inner_state_machine_definition.rendered}"
}

data "template_file" "inner_state_machine_definition" {
  template = "${file("state_machines/inner_state_machine.json")}"
  vars {
    send_success_lambda_arn = "${aws_lambda_function.send_success.arn}"
    send_failure_lambda_arn = "${aws_lambda_function.send_failure.arn}"
  }
}
