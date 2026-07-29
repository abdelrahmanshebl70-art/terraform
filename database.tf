resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "dbg"
  subnet_ids = [aws_subnet.database_1a.id,aws_subnet.database_2b.id]
  tags       = { Name = "dbg"}  
}
resource "aws_db_instance" "mysql_db" {
  identifier             = "retailedge-mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  max_allocated_storage  = 20
  
  db_name                = "retailedgedb"
  username               = "adminuser"
  password               = "SuperSecurePassword123" 
  
  multi_az               = false
  storage_encrypted      = false
  backup_retention_period = 1
  
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "retailedge-redis-subnet"
 subnet_ids = [aws_subnet.private_2a.id, aws_subnet.private_2b.id]
}
