resource "aws_db_subnet_group" "db_group" {
  name = "db_group"
  subnet_ids = [ 
    var.db_subnet1,
    var.db_subnet2
   ]
   tags = {
     Name = "Main-db-subnet-group"
   }
}

resource "aws_security_group" "db_sg" {
  name = "db_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [ var.ecs_sg ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "rds_sg"
  }
}

resource "aws_db_instance" "PostGreSql" {
  identifier = "postgresql-db"
  engine = "postgre"
  engine_version = "17.10"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  username = var.db_username
  password = var.db_password
  publicly_accessible = false
  multi_az = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [ 
    aws_security_group.db_sg.id
   ]
   backup_retention_period = 0
   deletion_protection = false
   tags = {
     Name = "RDS"
   }
}