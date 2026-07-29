resource "aws_lb_target_group" "app_tg" {
  name        = "app-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.shipl.id
  target_type = "instance"
}