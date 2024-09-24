resource "aws_db_subnet_group" "iccsdb_subnet" {
  name       = var.iccsdb_sub_name
  subnet_ids = [var.priv_sub_3a_id, var.priv_sub_4b_id] 
}

resource "aws_db_instance" "iccsdb" {
  identifier             = "iccsdb"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.4"
  username               = var.iccsdb_username
  password               = var.iccsdb_password
  db_name                = var.iccsdb_name
  db_subnet_group_name   = aws_db_subnet_group.iccsdb_subnet.name
  vpc_security_group_ids = [var.iccsdb_sg_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false

  #depends_on            = [aws_db_subnet_group.iccsdb-subnet]

    tags = {
    Name = "iccsdb"
  }
}
