# Module ec2-startstop
This module can be used to temporarily stop and restart a pre-defined set of EC2 instances in AWS in order to reduce costs. It can be configured with the following variables:
   * `ec2_instance_ids` (mandatory): a list of EC2 instance IDs to start and stop.
   * `cron_expr_start`: cron expression to trigger the start of the EC2 instances.
   * `cron_expr_stop`: cron expression to trigger the stop of the EC2 instances.
   * `region`: the region where the EC2 instances are located. This is an optional parameter. If no region variable is specified in the calling module, the aws_region data source is used to auto-determine the current region.

The code in the module is based on this article in the AWS user guide:
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html

# Additional notes
## Pre-commit hooks
This repository contains a [.pre-commit-config.yaml](.pre-commit-config.yaml) file. This file includes a list of git pre-commit hooks that are handy during development.
In order to activate the hooks, you need to install *pre-commit package manager* on your machine first (one-off action).
```
$ pip install pre-commit
```
Next you need to install the hooks listed in [.pre-commit-config.yaml](.pre-commit-config.yaml):
```
$ pre-commit install
```
pre-commit will now run on every commit. To manually run all hooks, you can issue
```
$ pre-commit run --all-files
```

More information about the yelp pre-commit framework can be found [here](http://pre-commit.com/)

IMPORTANT: There's also one *repository local hook* present in [.pre-commit-config.yaml](.pre-commit-config.yaml) with the name `zip_py_scripts`. It is responsible for archiving the `lambda_xxx.py` scripts in the `ec2-startstop` module. Please make sure this pre-commit hook is run before tagging the repo.