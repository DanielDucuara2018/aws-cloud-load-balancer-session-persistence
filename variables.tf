variable "region" {
    description = "Infrastructure region"
    type        = string
    default     = "eu-west-3"
}
variable "access_key_id" {
    description = "The access_key that belongs to the IAM user"
    type        = string
    sensitive   = true
    default     = ""
}
variable "secret_key_id" {
    description = "The secret_key that belongs to the IAM user"
    type        = string
    sensitive   = true
    default     = ""
}
variable "net_ip_range" {
    description = "The cidr of the vpc"
    default     = "192.168.0.0/16"
    type        = string
}
variable "subnet_ip_range_public" {
    description = "cidr blocks for the public subnets"
    default     = "192.168.1.0/24"
    type        = string
}
variable "subnet_ip_range_private01" {
    description = "cidr blocks for the private subnets"
    default     = "192.168.2.0/24"
    type        = string
}
variable "subnet_ip_range_private02" {
    description = "cidr blocks for the private subnets"
    default     = "192.168.3.0/24"
    type        = string
}
variable "keypair_name" {
    description = "name of the keypair"
    default     = "terraform_keypair_1"
    type        = string
}
variable "instance_type" {
    description = "The instance type of the EC2 instances"
    default     = "t3.nano"
    type        = string
}
