locals {
  dbs = { for db in var.db_config : db.identifier => db}
}

resource "aws_db_subnet_group" "my_db" {
  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "database" {
    for_each = local.dbs
    
  allocated_storage    = each.value.allocated_storage
  db_name              = each.value.db_name
  identifier           = each.value.identifier
  engine               = each.value.engine
  instance_class       = each.value.instance_class
  username             = each.value.username
  password             = each.value.password
  parameter_group_name = each.value.parameter_group_name
  publicly_accessible  = each.value.publicly_accessible
  skip_final_snapshot  = each.value.skip_final_snapshot
  port                 = each.value.port
  db_subnet_group_name = aws_db_subnet_group.my_db.name
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = each.value.tags
}