resource "aws_key_pair" "key" {
  key_name = var.aws_key_pair_key_name
  public_key = var.aws_key_pair_public_key
}

resource "aws_instance" "sami-oracle-ec2-gko" {
  ami  = var.ami
  instance_type = "t3.medium"
  key_name                    = "${aws_key_pair.key.key_name}" # you will need generate your own local openSSH key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.lab["az2"].id
  vpc_security_group_ids = [ aws_security_group.rds.id ]
  root_block_device {
    volume_size = 20
  }
  depends_on = [aws_db_instance.sami-oracle-rds-gko]
  # Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new AWS instance.
  provisioner "file" {
    content      = templatefile("${path.module}/scripts/oracle_commands.tpfl", {DB_URL = "${aws_db_instance.sami-oracle-rds-gko.address}:1521/ORACLE"})


    destination = "/tmp/oracle_commands"
  }
  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/oracle_commands",
      "sudo su /tmp/oracle_commands",
    ]
  }
  
  # # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ec2-user"
    # http://man.hubwiz.com/docset/Terraform.docset/Contents/Resources/Documents/docs/provisioners/connection.html
    private_key = file(aws_key_pair.key.key_name) # try file("./sami_oracle_id_rsa")
    host        = aws_instance.sami-oracle-ec2-gko.public_ip
  }


}


output "build" {
  value = {
    ip  = aws_instance.sami-oracle-ec2-gko.public_ip,
    dns = aws_instance.sami-oracle-ec2-gko.public_dns,
  }
}

