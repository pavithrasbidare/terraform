# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create Public Subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

# Create Private Subnets
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
}

# Create Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# Create Security Groups
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instances for Web Servers with Database Connection Example
resource "aws_instance" "web1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd php php-mysqlnd
              systemctl start httpd
              systemctl enable httpd
              echo "<?php
              \$servername = 'your-rds-endpoint';
              \$username = 'usecase-1';
              \$password = 'usecase-1';
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
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd php php-mysqlnd
              systemctl start httpd
              systemctl enable httpd
              echo "<?php
              \$servername = 'your-rds-endpoint';
              \$username = 'usecase-1';
              \$password = 'usecase-1';
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

# Create RDS MySQL Instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "usecase-1"
  password             = "usecase-1"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# Create S3 Bucket for Remote State Management
resource "aws_s3_bucket" "terraform_state" {
  bucket = "usecase-1"
  acl    = "private"
}

# Create DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Initialize Database with Sample Data
resource "null_resource" "db_init" {
  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.default.endpoint} -u usecase-1 -pusecase-1 -e "
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL
      );
      INSERT INTO users (name) VALUES ('John Doe'), ('Jane Smith'), ('Alice Johnson');
      " mydb
    EOT
  }

  depends_on = [aws_db_instance.default]
}

