# Documentation for ECS Launch Type EC2 Setup

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Configuration](#configuration)
3. [Resources Created](#resources-created)
   - [IAM Roles and Policies](#iam-roles-and-policies)
   - [VPC and Networking](#vpc-and-networking)
   - [EC2 Instances](#ec2-instances)
   - [ECS Cluster and Services](#ecs-cluster-and-services)
4. [Usage](#usage)
5. [CleanUp](#cleanup)

## Overview
This Terraform configuration sets up an Amazon Elastic Container Service (ECS) environment. It creates necessary AWS resources, including IAM roles, VPC, subnets, security groups, EC2 instances, an auto-scaling group, an ECS cluster, a capacity provider, task definitions, and an ECS service. The setup is designed to run containerized applications in a scalable manner.

## Prerequisites
- AWS Account
- Terraform installed on your local machine
- AWS CLI configured with appropriate permissions

## Configuration
- AWS Region: This configuration is set to use the `us-east-1` region. Make sure to adjust it based on your requirements.
- Variables: The configuration uses variables for `ami_id`, `instance_type`, `desired_capacity`, `max_size`, and `min_size`. Define these variables in a `variables.tf` file or provide them via command line.

## Resources Created
The following AWS resources are created by this configuration:

### IAM Roles and Policies
1. **ECS Task Execution Role (`aws_iam_role.ecs_task_execution_role`):**
   This role allows ECS tasks to pull container images from Amazon ECR and write logs to CloudWatch.
   - It has an assume role policy that permits ECS tasks to assume this role.
 
2. **IAM Policy Attachment for Task Execution (`aws_iam_policy_attachment.ecs_task_execution_policy`):**
   - Attaches the predefined Amazon ECS Task Execution Role policy to the ECS task execution role, granting the necessary permissions.

3. **ECR Read Policy (`aws_iam_policy.ecr_read_policy`):**
   - This policy grants permissions to read from ECR, allowing the ECS tasks to fetch Docker images.

4. **IAM Policy Attachment for ECR Read (`aws_iam_policy_attachment.ecr_read_policy_attachment`):**
   - Attaches the ECR read policy to the ECS task execution role.

5. **CloudWatch Logs Policy (`aws_iam_policy.cloudwatch_logs_policy`):**
   - This policy grants permissions to create and write logs in CloudWatch, enabling monitoring of ECS task logs.

6. **IAM Policy Attachment for CloudWatch Logs (`aws_iam_policy_attachment.cloudwatch_logs_policy_attachment`):**
   - Attaches the CloudWatch logs policy to the ECS task execution role.

7. **ECS Instance Role (`aws_iam_role.ecs_instance_role`):**
   - This role allows ECS EC2 instances to interact with AWS services, such as registering and deregistering themselves with the ECS service.

8. **ECS Instance Policy (`aws_iam_policy.ecs_instance_policy`):**
   - A policy that provides permissions for logging, describing EC2 instances, accessing ECR, and interacting with ECS.

9. **IAM Role Policy Attachment for ECS Instance (`aws_iam_role_policy_attachment.attach_ecs_instance_policy`):**
   - Attaches the ECS instance policy to the ECS instance role.

10. **IAM Instance Profile for ECS Instance Role (`aws_iam_instance_profile.ecs_instance_profile`):**
    - This instance profile is linked to the ECS instance role, allowing EC2 instances to assume the role.

### VPC and Networking
1. **Virtual Private Cloud (VPC) (`aws_vpc.main`):**
   - Creates a VPC with a CIDR block of `1.0.0.0/16` and enables DNS hostnames for better networking management.
 
2. **Public Subnet 1 (`aws_subnet.subnet`):**
   - Creates a public subnet in the VPC with a CIDR block of `1.0.1.0/24`, mapping public IPs on launch and located in availability zone `us-east-1a`.

3. **Public Subnet 2 (`aws_subnet.subnet2`):**
   - Creates a second public subnet in the VPC with a CIDR block of `1.0.2.0/24`, also mapping public IPs on launch and located in availability zone `us-east-1b`.

4. **Internet Gateway (`aws_internet_gateway.internet_gateway`):**
   - An internet gateway that allows communication between the VPC and the internet, enabling external access to the resources in the VPC.

5. **Route Table (`aws_route_table.route_table`):**
   - Defines routes for the VPC, directing all traffic (`0.0.0.0/0`) to the internet gateway.

6. **Route Table Associations (`aws_route_table_association`):**
   - Associates the route table with both public subnets, allowing them to use the defined routes for internet access.

### EC2 Instances
1. **Launch Template (`aws_launch_template.ecs_lt`):**
   - Defines a template for launching EC2 instances, specifying the AMI ID, instance type, key name for SSH access, security groups, IAM instance profile, block device mappings for storage, and user data for initialization (e.g., installing Nginx).
 
2. **Auto Scaling Group (`aws_autoscaling_group.ecs_asg`):**
   - Creates an auto-scaling group that automatically manages the scaling of EC2 instances based on defined capacity. It uses the launch template and specifies the subnets for instance deployment.

### ECS Cluster and Services
1. **ECS Cluster (`aws_ecs_cluster.ecs_cluster`):**
   - Creates an ECS cluster named `my-ecs-cluster` to manage the containerized applications.

2. **ECS Capacity Provider (`aws_ecs_capacity_provider.ecs_capacity_provider`):**
   - Defines a capacity provider that manages the scaling of EC2 instances in the auto-scaling group.

3. **ECS Cluster Capacity Providers (`aws_ecs_cluster_capacity_providers.example`):**
   - Associates the capacity provider with the ECS cluster and defines the default capacity provider strategy, specifying how tasks are distributed.

4. **ECS Task Definition (`aws_ecs_task_definition.ecs_task_definition`):**
   - Defines the task for the ECS service, including the container specifications, resource requirements (CPU and memory), and network settings.

5. **ECS Service (`aws_ecs_service.ecs_service`):**
   - Creates an ECS service that runs the defined task. It specifies the desired number of task instances, network configurations, deployment strategies, and triggers for redeployment.

## Usage
 1. **Clone the Repository:**
	```bash
	git clone <repository-url>
	```
 
 2. **Initialize Terraform:**
	
	```bashterraform init
	```

 3. **Review the Execution Plan:**
	
	```bash
	terraform plan
	```

 4. **Apply the Configuration:**
 
	```bash terraform apply
	```

5. **Access the Application: Once the resources are created, you can access your application using the public IP of the EC2 instances running your ECS tasks.**

## Cleanup

To remove all the created resources, run:

	terraform destroy


