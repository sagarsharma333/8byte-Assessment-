output "alb_dns_name" {
    description = "The DNS name of the ALB"
    value = aws_lb.main.dns_name
    }


output "rds_endpoint" {
    description = "The endpoint of the RDS instance"
    value = aws_db_instance.main.endpoint
    sensitive = true
    }

output "app_server_public_ip" {
    description = "The public IP of the app EC2 instance"
    value = aws_instance.app.public_ip
    }