resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "allow_psql" {
  name        = "${terraform.workspace}-allow_psql"
  description = "Allow RDS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "PSQL RDS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_psql"
  }
}

resource "aws_rds_cluster" "aurora" {
  engine                 = "aurora-postgresql"
  engine_version         = var.postgresql_version
  skip_final_snapshot    = true
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.allow_psql.id]
  master_username        = var.administrator_login
  master_password        = random_password.db_password.result
}

resource "aws_rds_cluster_instance" "postgresql" {
  cluster_identifier     = aws_rds_cluster.aurora.id
  engine                 = aws_rds_cluster.aurora.engine
  engine_version         = aws_rds_cluster.aurora.engine_version
  instance_class         = "db.t3.medium"
  #vpc_security_group_ids = [aws_security_group.allow_psql.id]

  publicly_accessible    = true
}

resource "null_resource" "create_databases" {
  for_each = toset(var.databases)

  provisioner "local-exec" {
    command = "createdb -h ${aws_rds_cluster.aurora.endpoint} -U ${var.administrator_login} ${each.value}"

    environment = {
      PGPASSWORD = random_password.db_password.result
    }
  }
}