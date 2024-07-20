# RDS Subnet Group
resource "aws_db_subnet_group" "private_db_subnet" {
  name        = "mysql-rds-private-subnet-group"
  description = "Private subnets for RDS instance"
  # Subnet IDs must be in two different AZ. Define them explicitly in each subnet with the availability_zone property
  subnet_ids = var.subnet_ids
}


resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Allows inbound access from ECS only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = [var.ecs_tasks_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# RDS Instance
resource "aws_db_instance" "rds" {
  allocated_storage       = 10           # Storage for instance in gigabytes
  identifier              =  var.name_rds
  storage_type            = "gp2"
  port                    = "3306"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro" # See instance pricing <https://aws.amazon.com/rds/postgres/pricing/?pg=pr&loc=2>
  multi_az                = false
  db_name                 = "wordpress" # name is deprecated, use db_name instead
  username                = "wordpress"
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7
  #password                = data.aws_ssm_parameter.db_password.value
  password                = "wordpress"
  db_subnet_group_name    = aws_db_subnet_group.private_db_subnet.name # Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group.

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
}



# Reference an SSM parameter for the password (already created in AWS Console)
# data "aws_ssm_parameter" "db_password" {
#   name = "/dev/djangoapi/db/password"
# }

# Create an IAM instance profile for the EC2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2-instance-profile-role"
  role = aws_iam_role.instance_role.name
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "instance_role" {
  name = "ec2-instance-role-rds"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the necessary IAM policy to the instance role
resource "aws_iam_role_policy_attachment" "instance_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
