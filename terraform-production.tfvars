project_name = "tap-sqlserver"
aws_region   = "us-east-1"

# Production-specific settings  
allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

# S3 endpoint configuration
s3_endpoint        = "com.amazonaws.us-east-1.s3"
enable_s3_endpoint = true