# An AWS hello-world in terraform


## Requirements

- Apply AWS best practices in solution architecture and security.
- Use an official, public, Debian, Ubuntu or Amazon Linux 2 AMI for any EC2 resources.
- Serve a basic "Hello, World" webpage.
- Scale capacity to meed demand.
- Manage unhealthy instances.
- Optional deploy role creation

# Design Choice

## Compute: Auto Scaling Group(ASG) with a pre-baked image behind an ALB

This system allows simple operation and response. while demonstrating CI/CD practices.

The general pattern will be to kick off a packer build of a new image then after validation update the ASG to the new configuration

## Layout: Terraform

The build will be created with a model based on responsibility separation.
The initial VPC, Role, Network and route53 zone will be done in one terraform module. This will then put the configuration information in an s3 bucket for consumption in the second stage system that will create the ASG, DNS entry, ACM and ALB

## Layout: AWS

- Account creation is considered out of scope for the base terraform creation.
- A single account will be used and credentials shared with different roles for Admin and scoped down

## CI process

Development should occur on a branch and be re-based prior to merge.

- Github will block non ff merges.
- Terraform configuration should include tests.
- Packer tests are currently out of scope.


## CD process

Once the initial readme and terraform configuration is done the repository will operate with a PR model with the following constraints.

- No additional approver required. As this is something with only one dev
- Continuous deployment from main branch
- Direct merges blocked

# Options


## Lambda + s3 + cognito

For a "simple" hello world application a lambda and s3 combination is likely going to be the cheapest and easily maintainable solution.

- Maintenance over time with Function As A Service systems can be quite problematic. FAAS Solutions take the [microservice murder mystery](https://twitter.com/honest_update/status/651897353889259520?lang=en) and turn it up to 11 (if not more)
- Single threaded but that's just my irritation
- Quick and easy to get running
- Low cost
- Rapid iteration is possible due to small scale execution object

While Lambda is an excellent place to start the use in this situation is unlikely to satisfy the challenge requirements

## Fargate

A simple run a container get donuts option

- Wonderfully simple
- Limited implementation prevents scope creep but limits extension
- Tight integration with AWS utils

Similar to the above running inside fargate does not meet the requirements for the challenge.

## EKS

This would provide a full kubernetes cluster with various options for runtime compute but has some significant maintenance and operation overheads.

- Flexible
- Maintenance heavy
- Benefits multiple teams and shared execution environments
- Expensive at small scales

EKS would be sufficiently significant for this challenge but the challenge does not appear to justify this deployment.


## ASG with static images

An auto scaling group configured to boot a Pre-baked image allows for a team to build a simple system that can scale dynamically and repair itself dynamically. Pre-baking the image as part of a CI/CD pipeline allows your product to respond reasonably rapidly without incurring substantial boot-time complexities

- Permanent artefact creation reduces dependencies when booting
- Primary image may be out of date over time and needs monitoring
- ASG will auto repair failed hosts.
- Boot time should be faster than EKS nodes but slower than additional pods


## ASG with docker

This system would be an effective mid-ground from a simplicity and quick responsiveness point of view. Allowing a static base image to boot and use a configured by cloud init docker image. Additionally this model allows effective isolation between system required packages and service libraries\packages.

Ultimately the goal of this style of system is to run with a very minimal OS. Unfortunately the AWS option of bottle rocket is only available with ECS or EKS and not standalone systems such as the GCP container OS.



# references:

[terraform provider documentation for aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[Terratest quickstart](https://terratest.gruntwork.io/docs/getting-started/quick-start/#example-2-terraform-and-aws)