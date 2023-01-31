resource "aws_instance" "sami-oracle-ec2" {
  ami  = var.ami
  instance_type = "t3.medium"
  key_name                    = "${aws_key_pair.key.key_name}" # you will need generate your own local openSSH key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.lab["az2"].id
  vpc_security_group_ids = [ aws_security_group.rds.id ]
  root_block_device {
    volume_size = 20
  }
}

output "build" {
  value = {
    ip  = aws_instance.sami-oracle-ec2.public_ip,
    dns = aws_instance.sami-oracle-ec2.public_dns,
  }
}


