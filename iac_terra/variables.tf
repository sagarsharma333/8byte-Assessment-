variable "aws_region" {
    type = string
    default = "us-east-1"  
}

variable "project_name" {
    type = string
    default = "8byte-devops"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "two public subnets for the alb"
    type = list(string)
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24"
    ]
}

variable "private_subnet_cidrs" {
    description = "RDS subnet group"
    type = list(string)
    default = [
        "10.0.11.0/24",
        "10.0.12.0/24"
    ]
}

variable "availability_zones" {
    description = "rds needs two availability zones for high availability"
    type = list(string)
    default = [
        "us-east-1a",
        "us-east-1b"
    ]
}

#variable "my_ip" {
#    description = "my ip address for ssh access"  
#    type = string
   # default = "106.51.221.196/32"
#}

#variable "key_name" {
#    description = "ec2 key pair  for ssh access"
#    type = string
#}


