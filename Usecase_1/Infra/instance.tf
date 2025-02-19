resource "aws_instance" "web1" {
  ami           = "ami-05d38da78ce859165"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2 php libapache2-mod-php php-mysql
              systemctl start apache2
              systemctl enable apache2

              echo "<?php
              \$servername = '${aws_db_instance.app_db.endpoint}';
              \$username = '${var.db_username}';
              \$password = '${var.db_password}';
              \$dbname = 'mydb';

              // Create connection
              \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

              // Check connection
              if (\$conn->connect_error) {
                die('Connection failed: ' . \$conn->connect_error);
              }

              \$sql = 'SELECT id, name FROM users';
              \$result = \$conn->query(\$sql);

              if (\$result->num_rows > 0) {
                while(\$row = \$result->fetch_assoc()) {
                  echo 'id: ' . \$row['id']. ' - Name: ' . \$row['name']. '<br>';
                }
              } else {
                echo '0 results';
              }
              \$conn->close();
              ?>" > /var/www/html/index.php
              EOF
}

resource "aws_instance" "web2" {
  ami           = "ami-05d38da78ce859165"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-2"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2 php libapache2-mod-php php-mysql
              systemctl start apache2
              systemctl enable apache2

              echo "<?php
              \$servername = '${aws_db_instance.app_db.endpoint}';
              \$username = '${var.db_username}';
              \$password = '${var.db_password}';
              \$dbname = 'mydb';

              // Create connection
              \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

              // Check connection
              if (\$conn->connect_error) {
                die('Connection failed: ' . \$conn->connect_error);
              }

              \$sql = 'SELECT id, name FROM users';
              \$result = \$conn->query(\$sql);

              if (\$result->num_rows > 0) {
                while(\$row = \$result->fetch_assoc()) {
                  echo 'id: ' . \$row['id']. ' - Name: ' . \$row['name']. '<br>';
                }
              } else {
                echo '0 results';
              }
              \$conn->close();
              ?>" > /var/www/html/index.php
              EOF
}