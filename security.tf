/*
    The RDS is allowed to accept traffic from the worker nodes
*/

resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress = [
    {
      description     = "Allow traffic from worker nodes to RDS"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [module.eks.node_security_group_id]
      #source_security_group_id = [module.eks.node_security_group_id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false

    }
  ]

  //  RDS can send out traffic anywhere with any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
  }
}
