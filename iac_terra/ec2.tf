data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64-gp2"]
    }
  
}

resource "aws_instance" "app" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro" 
    key_name = var.key_name

    subnet_id = aws_subnet.public[0].id
    vpc_security_group_ids = [aws_security_group.app.id]
    associate_public_ip_address = true
tags = {
        Name = "${var.project_name}-app"
    }
}