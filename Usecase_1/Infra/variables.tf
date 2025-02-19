variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "CIDR block for the first public subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  description = "CIDR block for the second public subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet1_cidr" {
  description = "CIDR block for the first private subnet"
  default     = "10.0.3.0/24"
}

variable "private_subnet2_cidr" {
  description = "CIDR block for the second private subnet"
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "Database engine version"
  default     = "mysql"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance"
  default     = 20
}

variable "db_username" {
  description = "Database username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  default     = "password123"
}