import json
import pytest

from aws_cdk import core
from nn-demo.nn_demo_stack import NnDemoStack


def get_template():
    app = core.App()
    NnDemoStack(app, "nn-demo")
    return json.dumps(app.synth().get_stack("nn-demo").template)


def test_sqs_queue_created():
    assert("AWS::SQS::Queue" in get_template())


def test_sns_topic_created():
    assert("AWS::SNS::Topic" in get_template())
