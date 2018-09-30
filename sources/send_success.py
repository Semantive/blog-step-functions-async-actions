import json

import boto3

# Config is not altered here because this Lambda works in push model, not pull one.
states_client = boto3.client('stepfunctions')


# noinspection PyUnusedLocal
def handler(event, context):
    task_token = event['task_token']
    # `state` is a single-element array because it is an output
    # from Parallel state. Here we're unwrapping real result of
    # inner Execution.
    output_state = event['state'][0]

    states_client.send_task_success(
        taskToken=task_token,
        output=json.dumps(output_state),
    )

    return event
