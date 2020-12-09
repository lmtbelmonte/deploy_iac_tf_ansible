# Luis merino : Despliegue en aws con terraform y ansible
# 
# Creacion de los security groups for the LB solo permitido TCP/80, TCP/443
# outbound access
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-master
  name        = "lb-sg"
  description = "Permitir el traffico hacia el load balancer"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Permitir tcp/443 desde cualquier sitio"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Permitir tcp/80 desde cualquier sitio"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Permitir salida a todo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creacion de los security groups para Jenkins TCP/8080, TCP/22
# full outbound
# en la region master 
# permitir trafico desde la region2  . la worker
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-master
  name        = "jenkins-sg"
  description = "Permitir entrada desde TCP/8080 y TCP/22"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Permitir tcp/22 desde nuestra ip externa"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "Permitir trafico tcp/8080 desde cualquier sitio"
    from_port       = var.webserver-port
    to_port         = var.webserver-port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }
  ingress {
    description = "Permitir trafico desde la 2 region la worker "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    description = "Permitir salida a todo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creacion de los security groups para Jenkins worker TCP/22
# Full outbound
# en la region 2 worker 
# En este caso solo recibe trafico del master y no del lb
resource "aws_security_group" "jenkins-sg-oregon" {
  provider    = aws.region-worker
  name        = "jenkins-sg-oregon"
  description = "Permitir entrada desde TCP/22"
  vpc_id      = aws_vpc.vpc_master_oregon.id
  ingress {
    description = "Permitir tcp/22 desde nuestra ip externa"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Permitir trafico desde la 1 region la master  "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    description = "Permitir salida a todo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}