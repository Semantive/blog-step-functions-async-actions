import json

import boto3

# Config is not altered here because this Lambda works in push model, not pull one.
states_client = boto3.client('stepfunctions')


# noinspection PyUnusedLocal
def handler(event, context):
    task_token = event['task_token']
    error_info = event['error_info']

    states_client.send_task_success(
        taskToken=task_token,
        error=error_info['Error'],
        cause=error_info.get('Cause', 'Cause is undefined.'),
    )

    return event
