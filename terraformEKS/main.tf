provider "aws" {
  region = "us-west-2"
}

############################

variable "cluster-name" {
  default = "Tera-EKS-cluster"
  type    = "string"
}

#################

data "aws_availability_zones" "available" {}

resource "aws_vpc" "Tera-EKS" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "Tera-EKS-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "Tera-EKS" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.Tera-EKS.id}"

  tags = "${
    map(
     "Name", "Tera-EKS-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "Tera-EKS" {
  vpc_id = "${aws_vpc.Tera-EKS.id}"

  tags {
    Name = "Tera-EKS"
  }
}

resource "aws_route_table" "Tera-EKS" {
  vpc_id = "${aws_vpc.Tera-EKS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Tera-EKS.id}"
  }
}

resource "aws_route_table_association" "Tera-EKS" {
  count = 2

  subnet_id      = "${aws_subnet.Tera-EKS.*.id[count.index]}"
  route_table_id = "${aws_route_table.Tera-EKS.id}"
}

#########################################
resource "aws_iam_role" "Tera-EKS-cluster" {
  name = "Tera-EKS-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "Tera-EKS-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.Tera-EKS-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "Tera-EKS-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.Tera-EKS-cluster.name}"
}

#===================================================================================

resource "aws_security_group" "Tera-EKS-cluster" {
  name        = "Tera-EKS-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.Tera-EKS.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Tera-EKS"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "Tera-EKS-cluster-ingress-workstation-https" {
  cidr_blocks       = ["103.6.32.110/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.Tera-EKS-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

#=======================================================

