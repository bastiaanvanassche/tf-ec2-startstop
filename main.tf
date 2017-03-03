resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_start_stop_ec2" {
  name = "lambda_start_stop_ec2"
  role = "${aws_iam_role.iam_role_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_region" "current" {
  current = true
}

resource "aws_lambda_function" "stop_ec2_instance" {
  description      = "stops EC2 instances"
  filename         = "${path.module}/lambda_stop.zip"
  function_name    = "lambda_stop_ec2_instance"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  handler          = "lambda_stop.lambda_handler"
  runtime          = "python2.7"
  timeout          = 10
  source_code_hash = "${base64sha256(file("${path.module}/lambda_stop.zip"))}"

  environment {
    variables = {
      EC2_INSTANCE_IDS = "${join(",",var.ec2_instance_ids)}"
      REGION           = "${coalesce(var.region,data.aws_region.current.name)}"
    }
  }
}

resource "aws_lambda_function" "start_ec2_instance" {
  description = "starts EC2 instances"

  # files embedded in modules need to be prepended with ${path.module} (https://www.terraform.io/docs/modules/create.html)
  filename      = "${path.module}/lambda_start.zip"
  function_name = "lambda_start_ec2_instance"
  role          = "${aws_iam_role.iam_role_for_lambda.arn}"

  # important: handler property needs to be '<filename>.<handler-function>', in our case the function resides
  # in a file called lambda_start.py and the function is called lambda_handler
  # reference: http://docs.aws.amazon.com/lambda/latest/dg/get-started-create-function.html
  handler = "lambda_start.lambda_handler"

  runtime          = "python2.7"
  timeout          = 10
  source_code_hash = "${base64sha256(file("${path.module}/lambda_start.zip"))}"

  environment {
    variables = {
      EC2_INSTANCE_IDS = "${join(",",var.ec2_instance_ids)}"
      REGION           = "${coalesce(var.region,data.aws_region.current.name)}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "trigger_start" {
  name                = "trigger_start"
  description         = "Trigger to start"
  schedule_expression = "${var.cron_expr_start}"
}

resource "aws_cloudwatch_event_target" "trigger_start" {
  rule = "${aws_cloudwatch_event_rule.trigger_start.name}"
  arn  = "${aws_lambda_function.start_ec2_instance.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_ec2_instance.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.trigger_start.arn}"
}

resource "aws_cloudwatch_event_rule" "trigger_stop" {
  name                = "trigger_stop"
  description         = "Trigger to stop"
  schedule_expression = "${var.cron_expr_stop}"
}

resource "aws_cloudwatch_event_target" "trigger_stop" {
  rule = "${aws_cloudwatch_event_rule.trigger_stop.name}"
  arn  = "${aws_lambda_function.stop_ec2_instance.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_ec2_instance.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.trigger_stop.arn}"
}
