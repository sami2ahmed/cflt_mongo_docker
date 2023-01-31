variable "region" {
  default     = "us-west-2" # this region must be used with the AMI below 
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "owner" {
  default = "sami"
}

# Amazon Linux 2 Kernel 5.10 AMI 2.0.20221210.1 x86_64 HVM gp2 (01-25-2022) in us-west-2 
variable "ami" {
  default = "ami-0ceecbb0f30a902a6"
}

variable "aws_key_pair_key_name" {
  description = "AWS openSSH keypair for EC2"
}

variable "aws_key_pair_public_key" {
  description = "AWS openSSH keypair for EC2"
}


 variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}
variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}