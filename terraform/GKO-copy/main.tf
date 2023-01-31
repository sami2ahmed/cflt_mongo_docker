data "aws_caller_identity" "current" {}

resource "aws_vpc" "lab" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner}-Managed"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "${var.owner}-Managed"
  }
}

# Attach route to route table: `aws_vpc.justin.default_route_table_id`
resource "aws_route" "lab_default_route" {
  route_table_id         = aws_vpc.lab.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab.id
}

output "vpc_id" {
  value = aws_vpc.lab.id
}

variable "subnet_mappings" {
  default = {
    "az1" = {
      "subnet" = 11,
      "az"     = "2b",
    },
    "az2" = {
      "subnet" = 12,
      "az"     = "2a",
    },
    "az3" = {
      "subnet" = 13,
      "az"     = "2c",
    },
  }
}

resource "aws_subnet" "lab" {
  for_each = var.subnet_mappings
  vpc_id = aws_vpc.lab.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.${each.value.subnet}.0/24"
  availability_zone_id = "usw2-${each.key}"
  # replace with "use1-${each.key}" for us-east-1, or "usw2-${each.key}" for us-west-2

  tags = {
    Name = "${var.owner}-Managed-${each.value.subnet}"
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.owner}-rds"
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port   = 1521 
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups  = null
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_groups  = null
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups  = null
  }

  tags = {
    Name = "${var.owner}-Managed"
  }
}

resource "aws_db_subnet_group" "rds_public_subnet_group" {
  name        = "aurora-rds-public-subnetgroup"
  description = "Public subnets for RDS instance"
# required list of subnets for which RDS will be deployed in 
  subnet_ids = [
    "${aws_subnet.lab["az1"].id}",
    "${aws_subnet.lab["az2"].id}",
    "${aws_subnet.lab["az3"].id}",
  ]
}

resource "aws_db_instance" "sami-oracle-rds-gko" {
  identifier             = "sami-oracle-rds-gko"
  instance_class         = "db.t3.small" # tasty not wasty small instance as this is not for heavy workload  
  engine                 = "oracle-ee"
  engine_version         = "19"
  db_subnet_group_name   = "${aws_db_subnet_group.rds_public_subnet_group.name}" # telling which subnets to put RDS in, without is RDS supposedly created in default VPC (mine did not work using default)
  vpc_security_group_ids = [ aws_security_group.rds.id ]
  publicly_accessible    = true
  skip_final_snapshot    = true
  license_model          = "bring-your-own-license"
  allocated_storage      = 20
  max_allocated_storage  = 50
  db_name  = "ORACLE"
  username = "samiadmin"
  port     = 1521
  password = var.db_password
  multi_az = false
  timeouts {
      create = "2h"
      delete = "2h"
    }    
    tags = {
      Name = "${var.owner}-Managed"
    }
  }