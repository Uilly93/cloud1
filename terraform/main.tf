resource "aws_key_pair" "cloud1" {
  key_name   = "cloud1-key"
  public_key = file("~/.ssh/aws/cloud1.pub")
}

resource "aws_security_group" "cloud1" {
  name = "cloud1-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.cloud1.key_name

  vpc_security_group_ids = [
    aws_security_group.cloud1.id
  ]

  tags = {
    Name = "cloud1"
  }
}
