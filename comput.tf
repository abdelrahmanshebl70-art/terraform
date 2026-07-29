resource "aws_launch_template" "my_temple" {
  name_prefix   = "retailedge-app-lt-"
  image_id      = var.my_ami
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello world" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my_rinstance"
    }
  }
}

resource "aws_autoscaling_group" "asg" { 
  name_prefix         = "retailedge-asg-"
  vpc_zone_identifier = [aws_subnet.private_2a.id, aws_subnet.private_2b.id]
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.my_temple.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }    
  target_group_arns = [aws_lb_target_group.app_tg.arn]
  health_check_type = "ELB"
}
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "target-tracking-cpu"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }
  target_value = 60.0
}
}
resource "aws_autoscaling_schedule" "black_friday_scale_up" {
  scheduled_action_name  = "scale-up-friday-night"
  min_size               = 6
  max_size               = 10
  desired_capacity       = 6
  recurrence             = "0 20 * * FRI" 
  autoscaling_group_name = aws_autoscaling_group.asg.name
}