resource "aws_vpc" "shipl" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true

  tags = {
    Name = "shipl"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" 
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.2.0/24"    
  availability_zone = "us-east-1b"
  tags = { Name = "public_1b" }
}
resource "aws_subnet" "private_2a" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private_2a" }
}
resource "aws_subnet" "private_2b" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "private_2b" }
}
resource "aws_subnet" "database_1a" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.7.0/24"   
  availability_zone = "us-east-1a"
  tags = {
    Name = "database_1a"
  }
}

resource "aws_subnet" "database_2b" {
  vpc_id            = aws_vpc.shipl.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "database_2b" }
}
