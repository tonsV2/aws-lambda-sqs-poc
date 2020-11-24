
resource "aws_db_subnet_group" "db" {
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "rds" {
  name = "mydatabase"
  allocated_storage = 10
  engine = "postgres"
  engine_version = "11.5"
  instance_class = "db.t2.micro"
  username = random_string.username.result
  password = random_password.password.result
  skip_final_snapshot = true
  apply_immediately = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.db.name
}

resource "random_string" "username" {
  length = 32
  special = false
}

resource "random_password" "password" {
  length = 32
  special = false
}

