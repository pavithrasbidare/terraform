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

resource "null_resource" "db_init" {
  provisioner "local-exec" {
    command = <<EOT
      aws rds modify-db-instance --db-instance-identifier my-rds-instance --apply-immediately --enable-iam-database-authentication
      aws rds wait db-instance-available --db-instance-identifier my-rds-instance
      mysql -h ${aws_db_instance.app_db.endpoint} -u ${var.db_username} -p ${var.db_password} -e "
      CREATE DATABASE IF NOT EXISTS mydb;
      CREATE TABLE IF NOT EXISTS mydb.users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL
      );
      INSERT INTO mydb.users (name) VALUES ('John Doe'), ('Jane Smith'), ('Alice Johnson');
      "
    EOT
  }

  depends_on = [aws_db_instance.app_db]
}