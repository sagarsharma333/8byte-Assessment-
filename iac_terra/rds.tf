resource "aws_db_subnet_group" "main" {
    name = "${var.project_name}-rds-subnet-group"
    subnet_ids = aws_subnet.private[*].id

    tags = {
        Name = "${var.project_name}-rds-subnet-group"
    }
  
}
resource "aws_db_instance" "main" {
    identifier = "${var.project_name}-rds-instance"
    allocated_storage = 20
    engine = "postgres"
    engine_version = "16"
    instance_class = "db.t3.micro" #keepin it free

    db_name = "appdb"
    username = "appadmin"
    password = var.db_password 

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.rds.id]

    multi_az = false
    publicly_accessible = false

    backup_retention_period = 1 #this is a simple backup retention for disaster management increase this value for real use cases #free tier
    skip_final_snapshot = true  #delete the snapshot when the db is deleted keeping it freeeeeeee    
}