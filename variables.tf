// variables.tf

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-04a81a99f5ec58529"  // Change this to your desired AMI ID
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size for the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum size for the Auto Scaling Group"
  type        = number
  default     = 1
}
