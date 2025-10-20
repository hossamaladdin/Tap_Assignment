# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rule - SSH Ingress
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.bastion.id
  description       = "Allow SSH access from specified CIDR blocks"
}

# Security Group Rule - Egress (allow all)
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound traffic"
}

# IAM Role for Bastion
resource "aws_iam_role" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Secrets Manager access
resource "aws_iam_role_policy" "bastion_secrets" {
  name_prefix = "${var.name_prefix}-bastion-secrets-"
  role        = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach SSM managed policy for Session Manager
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-"
  role        = aws_iam_role.bastion.name

  tags = var.tags
}

# User data script
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    yum update -y
    
    # Install SQL Server tools
    curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/msprod.repo
    ACCEPT_EULA=Y yum install -y mssql-tools18 unixODBC-devel
    
    # Add SQL Server tools to PATH
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/profile.d/mssql.sh
    
    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    yum install -y unzip
    unzip awscliv2.zip
    ./aws/install
    
    # Install jq for JSON parsing
    yum install -y jq
    
    # Create connection script
    cat > /home/ec2-user/connect_to_rds.sh << 'SCRIPT'
    #!/bin/bash
    
    # Get RDS endpoint from instance tags or parameter
    RDS_ENDPOINT=$1
    
    if [ -z "$RDS_ENDPOINT" ]; then
      echo "Usage: $0 <rds-endpoint>"
      echo "Example: $0 mydb.cluster-abc123.us-east-1.rds.amazonaws.com"
      exit 1
    fi
    
    # Get credentials from Secrets Manager
    SECRET_ARN="${var.secret_arn}"
    AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    
    echo "Retrieving database credentials from Secrets Manager..."
    SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $AWS_REGION --query SecretString --output text)
    
    DB_USERNAME=$(echo $SECRET_JSON | jq -r .username)
    DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)
    
    echo "Connecting to SQL Server at $RDS_ENDPOINT..."
    echo "Username: $DB_USERNAME"
    echo ""
    
    # Connect using sqlcmd
    /opt/mssql-tools18/bin/sqlcmd -S $RDS_ENDPOINT -U $DB_USERNAME -P "$DB_PASSWORD" -C
    SCRIPT
    
    chmod +x /home/ec2-user/connect_to_rds.sh
    chown ec2-user:ec2-user /home/ec2-user/connect_to_rds.sh
    
    # Create README
    cat > /home/ec2-user/README.txt << 'README'
    ========================================
    Bastion Host for RDS SQL Server Access
    ========================================
    
    This bastion host provides secure access to your RDS SQL Server instance.
    
    Connection Instructions:
    ------------------------
    
    1. Connect to SQL Server:
       ./connect_to_rds.sh <rds-endpoint>
    
    2. The script will:
       - Retrieve credentials from AWS Secrets Manager
       - Connect to the database using sqlcmd
    
    3. Available tools:
       - sqlcmd (SQL Server command-line tool)
       - aws cli (for Secrets Manager access)
       - jq (JSON parsing)
    
    Example:
    --------
    ./connect_to_rds.sh mydb.cluster-abc123.us-east-1.rds.amazonaws.com
    
    Once connected, you can run SQL queries:
    SELECT @@VERSION;
    GO
    
    For more information about sqlcmd:
    https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility
    
    ========================================
    README
    
    chown ec2-user:ec2-user /home/ec2-user/README.txt
    
    echo "Bastion host setup complete!"
  EOF
}

# EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion"
    }
  )
}

# Elastic IP for Bastion (optional but recommended for stable SSH access)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion-eip"
    }
  )
}
