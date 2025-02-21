resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

resource "aws_db_instance" "app_db" {
  identifier = "my-rds-instance"
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = var.db_engine
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  multi_az             = true

  tags = {
    Name = "app-db"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.app_db.endpoint
}
