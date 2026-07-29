output "vpc_id" {
 
  value       = aws_vpc.shipl.id
}

output "database_endpoint" {
  
  value       = aws_db_instance.mysql_db.endpoint
}

output "autoscaling_group_name" {
  
  value       = aws_autoscaling_group.asg.name
}