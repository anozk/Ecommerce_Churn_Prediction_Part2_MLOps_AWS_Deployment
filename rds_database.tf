
# Variables (from secrets.tfvars)

variable "db_username" {
  description = "Master username for RDS PostgreSQL"
  type        = string
  sensitive   = true
  default     = "master"
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL"
  type        = string
  sensitive   = true
  default     = var.db_password
}


# Security Group for RDS

resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = "vpc-0d5534ea74dfb6a56" # Replace with your actual VPC ID

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}


# Subnet Group for RDS

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-postgres-subnet-group"
  subnet_ids = [
    "subnet-0751c08c7726d1be7",
    "subnet-092e4d9ecdb9389e8",
    "subnet-02dc466daa3655238",
    "subnet-0567b26a1df6f8b60",
    "subnet-06febe943001359b6",
    "subnet-0d3a6f58aa5a2673a",
  ]

  tags = {
    Name = "rds-postgres-subnet-group"
  }
}



# RDS PostgreSQL Instance

resource "aws_db_instance" "postgres_instance" {
  identifier              = "postgres-database"
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  apply_immediately       = true
  
  username                = var.db_username
  password                = var.db_password
  port                    = 5432

  multi_az                = false            # change to true for Multi-AZ
  publicly_accessible     = true            
  skip_final_snapshot     = true             # skip snapshot on destroy (dev only)

  backup_retention_period = 7
  deletion_protection     = false
  performance_insights_enabled = true

  tags = {
    Name = "postgres-database"
    Environment = "dev"
  }
}
