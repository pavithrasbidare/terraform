resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-subnet-2"
  }
}