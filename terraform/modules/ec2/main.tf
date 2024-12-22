resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}

# CloudWatch Agent IAM role
resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.instance_name}-cloudwatch-role"

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
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = "${var.instance_name}-cloudwatch-profile"
  role = aws_iam_role.cloudwatch_agent.name
}
