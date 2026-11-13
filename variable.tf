variable "my_ami" {
  type    = string
  default = "ami-0c02fb55956c7d316"
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}
