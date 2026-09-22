# COMPLIANT: restricted SSH access
resource "aws_security_group" "compliant_sg" {
  name        = "compliant-restricted-sg"
  description = "SSH restricted to a single admin IP"

  ingress {
    description = "SSH from admin IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"]
  }
}

# NON-COMPLIANT: SSH open to the world
resource "aws_security_group" "noncompliant_sg" {
  name        = "noncompliant-open-sg"
  description = "SSH open to the entire internet"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# COMPLIANT: scoped IAM policy
resource "aws_iam_policy" "compliant_policy" {
  name        = "compliant-scoped-policy"
  description = "Least-privilege policy scoped to specific S3 actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]
      Resource = "arn:aws:s3:::example-compliant-data-bucket/*"
    }]
  })
}

# NON-COMPLIANT: wildcard admin-equivalent policy
resource "aws_iam_policy" "noncompliant_policy" {
  name        = "noncompliant-wildcard-policy"
  description = "Overly broad policy granting full access to everything"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
