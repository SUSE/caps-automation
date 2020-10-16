resource "random_password" "db_password" {
  length           = 24
  special          = false
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_psql" {
  name        = "${terraform.workspace}-allow_psql"
  description = "Allow RDS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "RDS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
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

resource "aws_db_instance" "postgresql" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = var.postgresql_version
  instance_class       = "db.t3.medium"
  password             = random_password.db_password.result
  skip_final_snapshot  = true
  storage_encrypted    = true
  vpc_security_group_ids = [aws_security_group.allow_psql.id]
  username             = var.administrator_login
}

#resource "aws_rds_cluster" "postgresql" {
#  cluster_identifier   = var.name
#  engine               = "aurora-postgresql"
#  master_username      = var.administrator_login
#  master_password      = random_password.db_password.result
#  skip_final_snapshot  = trueZZ
#}

#  public_network_access_enabled    = true
#  ssl_enforcement_enabled          = true
#  ssl_minimal_tls_version_enforced = "TLS1_2"
