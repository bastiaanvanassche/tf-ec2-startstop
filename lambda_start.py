import os
import boto3

# parse comma-separated list of ec2 instance ids
instances = [instance.strip() for instance in str.split(os.environ.get('EC2_INSTANCE_IDS'), ',')]

# aws region, e.g. eu-west-1
region = os.environ.get('REGION')


def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.start_instances(InstanceIds=instances)
    print 'started your instances: ' + str(instances)
