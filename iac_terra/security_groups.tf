resource "aws_security_group" "alb" {
    name = "${var.project_name}-alb-sg"
    description = "https from net"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "http from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  
    }

    ingress {
        description = "https from anywhere"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "app" {
    name = "${var.project_name}-app-sg"
    description = "HTTP from alb, SSH from ip"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "HTTP from ALB"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }
    ingress {
        description = "SSH from my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds" {
    name = "${var.project_name}-rds-sg"
    description = "Postgres from app"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "Postgres from app"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.app.id]
    }
    ingress {
        description = "Postgres from my IP"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] #send it
    }
}