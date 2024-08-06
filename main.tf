// main.tf


// Creating the ECS Task Execution Role ///////////////////////////////

# In this blcok we are specifying that only the ECS tasks service (ecs-tasks.amazonaws.com) can assume the IAM role named ecs_task_execution_role.
# This means that when an ECS task is running, it can use this role to get temporary permissions to perform actions allowed by any attached policies.

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonECSTaskExecutionRolePolicy

# In this block weare attaching the policy identified by the ARN arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy to the IAM role ecs_task_execution_role. 
# This means that the role will inherit the permissions defined in that policy, allowing ECS tasks that assume this role to perform the actions specified in that policy.

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecsTaskExecutionRolePolicyAttachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach additional permissions if needed

# In the following block of code we are defining an IAM policy named ECRReadPolicy.
# This policy allows the following actions related to Amazon Elastic Container Registry (ECR):
# ecr:BatchGetImage: Allows the action of retrieving multiple images from the ECR repository.
# ecr:DescribeRepositories: Allows the action of listing and describing repositories in ECR.
# ecr:GetAuthorizationToken: Allows the action of obtaining a token needed to authenticate to the ECR service.

# Resource Set to "*" (Resource  = "*"):
# By setting the Resource to "*", you are specifying that the allowed actions (ecr:BatchGetImage, ecr:DescribeRepositories, and ecr:GetAuthorizationToken)
# can be applied to all repositories and images within ECR in your AWS account. This means that the policy does not restrict the IAM role or user to a specific repository or image or a tag;
# it allows actions on any repository or image or tag present in your ECR.


resource "aws_iam_policy" "ecr_read_policy" {
  name   = "ECRReadPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken"
        ]
        Resource  = "*"
      }
    ]
  })
}

// This block of code creates an IAM policy attachment
// resource "aws_iam_policy_attachment" "ecr_read_policy_attachment" {
  // Assigning a custom name to uniquely identify this policy attachment in Terraform
 // name       = "ECRReadPolicyAttachment"
  
  // Attaching the policy to the IAM role named 'ecs_task_execution_role'
 // roles      = [aws_iam_role.ecs_task_execution_role.name]
  
  // Specifying the ARN of the 'ECRReadPolicy' IAM policy to be attached to the role
  // policy_arn = aws_iam_policy.ecr_read_policy.arn
//}


resource "aws_iam_policy_attachment" "ecr_read_policy_attachment" {
  name       = "ECRReadPolicyAttachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}

# In the following block of code, we are creating an AWS IAM policy with a custom name "CloudWatchLogsPolicy." 
# This policy, when attached to an IAM user or role, will allow them to perform two actions: 
# "logs:CreateLogStream" and "logs:PutLogEvents" on any resources, meaning on all log groups and log streams 
# within the AWS account.

# By setting Resource to "*" (Resource="*"), the policy permits the specified actions 
# (logs:CreateLogStream and logs:PutLogEvents) on all log groups and log streams within the AWS account. 
# This means that any log group and any log stream can be used for these actions, 
# without limitation to specific ones.

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name   = "CloudWatchLogsPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "*"
      }
    ]
  })
}

# In the following block of code, we are creating an IAM policy attachment with a custom name "CloudWatchLogsPolicyAttachment." 
# This attachment will link the policy identified by aws_iam_policy.cloudwatch_logs_policy.arn to the IAM role named ecs_task_execution_role.
# The role will then have the permissions defined in the "CloudWatchLogsPolicy" attached to it.

resource "aws_iam_policy_attachment" "cloudwatch_logs_policy_attachment" {
  name       = "CloudWatchLogsPolicyAttachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}



// Creating the ECS Instance Role ////////////////////////////// 

# In the following block of code, we are creating an IAM role with a custom name "ecs_instance_role." 
# This role is specifically designed to be assumed by EC2 instances, as indicated by the "Principal" field specifying "ec2.amazonaws.com."
# This means that only EC2 instances can assume this IAM role, allowing them to perform actions granted by this role's attached policies.
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}



# In the following block of code, we are defining an IAM policy with the custom name "AmazonEC2ContainerServiceforEC2Role".
# This policy has several statements that specify which actions are allowed on certain AWS services,

resource "aws_iam_policy" "ecs_instance_policy" {
  name        = "AmazonEC2ContainerServiceforEC2Role"
  description = "Policy for ECS EC2 instance role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*" # Allows these actions on all CloudWatch Logs groups and streams (any log group and stream)
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*" # Allows these actions on all EC2 resources (any EC2 instance, region, subnet, or security group)
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"  # Allows these actions on all ECR repositories (any repository in Amazon ECR)
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll"
        ]
        Resource = "*"  # Allows these actions on all ECR repositories (any repository in Amazon ECR)
      }
    ]
  })
}

# In the following block of code, we are attaching an IAM policy to an IAM role.
# The role parameter is set to aws_iam_role.ecs_instance_role.name, which refers to the IAM role locally named "ecs_instance_role".
# The policy_arn parameter is set to aws_iam_policy.ecs_instance_policy.arn, which fetches the ARN of the IAM policy locally named "ecs_instance_policy".
# This attachment allows the locally named "ecs_instance_role" to use the permissions defined or allowed in locally named policy "ecs_instance_policy".

resource "aws_iam_role_policy_attachment" "attach_ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_instance_policy.arn
}


// Creating the IAM Instance Profile for the ECS Instance Role

# name = "ecs_instance_profile" assigns a custom name to the IAM Instance Profile.
# The line role = aws_iam_role.ecs_instance_role.name specifies which IAM role this instance profile will be associated with.
# aws_iam_role.ecs_instance_role.name refers to the IAM role that we previously created (the one named locally ecs_instance_role). 
# This means that the IAM Instance Profile will use the permissions defined in this role.


resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}












// Creating the VPC
resource "aws_vpc" "main" {
  cidr_block           = "1.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

// Creating the two public subnets
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "1.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "1.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

// Creating the internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet_gateway"
  }
}

// Creating the route table 
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

// Associating the route table with subnet
resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

// Creating the security group
resource "aws_security_group" "security_group" {
  name = "ecs-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS_Security_Group"
  }
}

// Configuring the EC2 instances
resource "aws_launch_template" "ecs_lt" {

  // Define a new AWS launch template for ECS instances with a name prefix
  name_prefix   = "ecs-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name               = "deployer-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]

  // Specify the IAM instance profile to attach to the EC2 instances
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name  // Updated line
  }

  // the block device mapping for the EBS volume
  block_device_mappings {
    device_name = "/dev/xvda" // The device name for the root EBS volume, if we want to access the storage of ebs volume through the ec2 instance we will use the path "/dev/xvda
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }

  user_data = base64encode(<<-EOF
             #!/bin/bash
             sudo apt-get update
             sudo apt-get install -y nginx
             sudo systemctl start nginx
             sudo systemctl enable nginx
             echo '<!doctype html>
             <html lang="en"><h1>Home page!</h1></br>
             </html>' | sudo tee /var/www/html/index.html
              EOF
  )
}


// Creating the Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [aws_subnet.subnet.id, aws_subnet.subnet2.id] // This line specifies the subnets where the instances in the Auto Scaling Group will be launched. 
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest" // "$Latest" means it will use the latest version of the template.
  }
  tag {
    key                 = "AmazonECSManaged" # AmazonECSManaged is a standaradized tag and when the value of the tag AmazonECSManaged is set to "true", it typically indicates that the resources 
                                             # (in this case, the instances in the Auto Scaling Group) are managed by Amazon ECS (Elastic Container Service).
    value               = "true"
    propagate_at_launch = true //  When set to true, this means the tag will be applied to the instances when they are launched.
  }
}

// Creating the ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

// Defining the capacity provider
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "test1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    # This starts a block that configures managed scaling settings for the capacity provider. Managed scaling allows ECS to automatically 
    # adjust the number of EC2 instances in your auto-scaling group based on the demand for your tasks.
    managed_scaling {
      maximum_scaling_step_size = 1000 # This line sets the maximum number of tasks that can be added (scaled up) in a single scaling action to 1000. 
                                       # This helps to control how quickly the capacity provider can respond to increases in demand.
      minimum_scaling_step_size = 1    # This line sets the minimum number of tasks that can be added in a single scaling action to 1. This means that even a small
                                       # increase in demand will result in at least one task being added.
      status                    = "ENABLED"
      target_capacity           = 3 # This line sets the target capacity for the managed scaling to 3. This means that ECS will try to maintain a minimum of 3 tasks running in your service.
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name] # This line specifies the capacity providers that will be used by the ECS cluster.
                                                                              # It uses an array notation to list the capacity provider(s). In this case, it references
                                                                              # an existing ECS capacity provider defined elsewhere in your Terraform code, named ecs_capacity_provider.
  
  # This begins a block that defines the default capacity provider strategy for the ECS cluster.
  # This strategy determines how ECS will use the specified capacity providers to run tasks.hcl
  default_capacity_provider_strategy {
    base              = 1  # This line sets the base value for the capacity provider strategy to 1. This means that at least 1 task will always be run using
                           # this capacity provider.

    weight            = 100 # This line sets the weight of the capacity provider to 100. The weight determines how many tasks will be assigned to this capacity provider relative to other capacity providers.
                            # A higher weight means that this capacity provider will be preferred when launching new tasks.
    
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name # This line specifies the capacity provider to be used in the strategy.
                                                                             # It references the previously defined ECS capacity provider named ecs_capacity_provider.
  }
}

// Creating the ECS task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "my-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu                = 256

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "dockergs"
      image     = "public.ecr.aws/f9n5f1l7/dgs:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

// Creating the ECS service
resource "aws_ecs_service" "ecs_service" {  # Define a new ECS service resource named 'ecs_service'.
  name            = "my-ecs-service"        # Set the name of the ECS service to 'my-ecs-service'.
  cluster         = aws_ecs_cluster.ecs_cluster.id  # Reference the ID of the ECS cluster where the service will run.
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn  # Reference the ARN of the task definition to be used by the service.
  desired_count   = 2                        # Set the desired number of task instances to 2.

  network_configuration {                      # Begin the network configuration block for the service.
    subnets         = [aws_subnet.subnet.id, aws_subnet.subnet2.id]  # Specify the subnets where the service's tasks will run.
    security_groups = [aws_security_group.security_group.id]  # Specify the security group that controls traffic to/from the tasks.
  }

  force_new_deployment = true                 # Force a new deployment of the service, restarting tasks even if there are no changes in the task definition.
  
  placement_constraints {                      # Begin the placement constraints block for task placement.
    type = "distinctInstance"                  # Ensure that each task runs on a different EC2 instance for improved availability.
  }

  triggers = {                                # Define triggers that force a redeployment of the service.
    redeployment = timestamp()                 # Use the current timestamp as a trigger to signal a redeployment whenever the configuration is applied.
  }

  capacity_provider_strategy {                 # Begin the capacity provider strategy block for managing task resources.
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name  # Reference the capacity provider to be used for task placement.
    weight            = 100                    # Set the weight for this capacity provider to 100, prioritizing it for task allocation.
  }

  depends_on = [aws_autoscaling_group.ecs_asg]  # Specify a dependency on the ECS auto-scaling group to ensure it is created before the service.
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// NOTES 

# The auto-scaling group determines the maximum number of tasks that can be assigned to the ECS capacity provider. Here's how it works:

# How the Auto-Scaling Group Determines Task Capacity
# Instance Types: The auto-scaling group contains a specific type of EC2 instance (e.g., t2.micro, m5.large). Each instance type has defined limits for CPU and memory.

# Resource Allocation: When you define ECS tasks, you specify the amount of CPU and memory that each task requires. The total number of tasks that can run on the EC2 instances
# in the auto-scaling group depends on:

# The resources available from the EC2 instances.
# The resource allocation specified for each ECS task.
# Capacity Provider Integration: The capacity provider is linked to the auto-scaling group, meaning that the tasks launched by ECS will utilize the EC2 instances
# managed by that auto-scaling group. The capacity provider effectively uses the instances in the group to meet the demand for tasks.

# Example Scenario:

# If your auto-scaling group is set to maintain 2 t2.micro instances, and each t2.micro can handle 2 tasks (assuming each task requires 0.5 vCPU and 1 GB of RAM),
# then the maximum number of tasks that the capacity provider can run is 4 tasks (2 instances × 2 tasks per instance).
# If the auto-scaling group scales up to 3 instances, then the capacity provider can handle up to 6 tasks.












# The timestamp() function in this context is not used for storing the current time and date for any other purpose. Instead, its main role is to serve as a dynamic value that changes every time the configuration is applied.

# Key Points about timestamp():
# Change Indicator: It acts as an indicator that a change has occurred in the configuration. Each time you run terraform apply, timestamp() generates a new current time value, signaling to ECS that something has changed, which prompts a redeployment.

# Forcing Redeployment: By updating the value in the triggers block, ECS sees it as a modification in the configuration, leading to the restart of tasks in the service.

# Summary
# So, in short, the timestamp() function's purpose here is to inform ECS of a configuration change and ensure that redeployment happens whenever the Terraform configuration is applied, rather than to keep track of the actual date and time for other purposes.
