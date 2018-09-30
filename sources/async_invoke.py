import json
import os

import boto3
from botocore.config import Config

# ARN of the Activity that is monitored by this Lambda function.
ASYNC_ACTION_ACTIVITY_ARN = os.environ['ASYNC_ACTION_ACTIVITY_ARN']

# ARN of nested State Machine that implements long-running asynchronous process.
NESTED_STATE_MACHINE_ARN = os.environ['NESTED_STATE_MACHINE_ARN']

# Boto3 client for Step Functions. `read_timeout` is set to 65 seconds because
# AWS service may respond after maximum of 60 seconds.
states_client = boto3.client('stepfunctions', config=Config(read_timeout=65))


# `event` is ignored because only finished Activity will resume Execution
# and result from Activity Task is important to the later parts of Execution.
# This Lambda function is strictly technical part of a State Machine and its
# result serves only debugging purposes.
#
# noinspection PyUnusedLocal
def async_invoke_handler(event, context):
    # Make an attempt to get Task scheduled for Activity representing asynchronous
    # process.
    activity_task_response = states_client.get_activity_task(
        activityArn=ASYNC_ACTION_ACTIVITY_ARN,
        workerName=context.function_name,
    )

    # Check if Task is present and raise an error otherwise.
    if 'taskToken' not in activity_task_response:
        raise MissingScheduledActivityTaskException()

    print(f'Task token: {activity_task_response["taskToken"]}')

    # Prepare input for nested State Machine. State data is taken from Activity Task.
    # State passed to Lambda is ignored.
    input_for_nested_execution = {
        'task_token': activity_task_response['taskToken'],
        'state': json.loads(activity_task_response['input']),
    }

    # Start nested State Machine. ARN of the nested State Machine is specified
    # as environment variable however it could be as well be taken from
    # Execution's state - this way we could dynamically start any State Machine.
    nested_execution_response = states_client.start_execution(
        stateMachineArn=NESTED_STATE_MACHINE_ARN,
        input=json.dumps(input_for_nested_execution),
    )

    # Place nested Execution ARN as output for eventual troubleshooting purposes.
    return {
        'nested_execution_arn': nested_execution_response['executionArn'],
    }


# Specific exception representing case when no Activity is scheduled.
# This can be later handled in State Machine by setting up retry.
class MissingScheduledActivityTaskException(Exception):
    pass
