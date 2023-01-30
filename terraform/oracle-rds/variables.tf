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

resource "aws_key_pair" "key" {
  key_name = "sami_oracle_id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPJQezmX3qyOYZY4OXTGS6gVD51wzJY6cD2Sc7N5RT1uGCIrR6GGgI3ee0w+LqS+QHoZi8A9wr2JPk+fW+5ZMGdOTmCriKzdaRS57xCdxNnqI7DFhvEo2Z5h1TJeVgxZxD4V0hVimcNWvRx3Gfsp7dAPCPxSFl2lJPKMXTi0UegjvhxrfzKAH5JksGfJeLJIuWOoWvTbBlbZ6CKdy0BBHM7XAnfLgSQQBTdQTaR7JLCLDzQOs4+3hr3cYoNHsu2tFIiqUWnLm04o283jQbasKDJ9736H6Te7BJf28jAtf9eqPIACe7oQmSd9aqJ90wkb0Y0w44+guwjZEs5OqwLsHRdFg8/Zi9qm0vo7VfXBhAv16/qJuvr7R63RGw/JiWZULWr1jBS6HQOk4fr2Ue4QHV4iSL1NEFYpgbmE9gAnW7e9bcZrdPhjkfxk/GfqFUIaUWbQ1ryMtCpn/ypQURFUjiG/rEzk+m1wFeNTi5CjYXD1OFGEUNyioiXRGlkC7yq/s= samiahmed@SamiAhmedMBP16"
}

 