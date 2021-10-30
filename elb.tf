provider "aws" {
	region = "ap-south-1"
}

resource "aws_lb_target_group" "NewTG" {
 health_check {
	interval = 10
	path = "/"
	protocol = "HTTP"
	timeout = 5
	healthy_threshold = 2
 }

	name = "my-test-tg"
	port = 80
	protocol = "HTTP"
	target_type = "instance"
	vpc_id = "vpc-6b4b9c00"
}

resource "aws_lb_target_group_attachment" "TG1" {
  target_group_arn = "${aws_lb_target_group.NewTG.arn}"
  target_id        = "i-0ea9cd793480b17aa"
  port             = 80
}

resource "aws_lb" "a" {
  name     = "MyElb"
  internal = false

security_groups = [
    "${aws_security_group.Mysg.id}",
  ]
subnets = [
"subnet-5524d83e",
"subnet-6ce9c420",
]

ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.a.arn}"
  port              = 80
  protocol          = "HTTP"

default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.NewTG.arn}"
  }
}
resource "aws_instance" "Albinstance" { 
	ami = "ami-041d6256ed0f2061c"
	key_name = "HTC"
	instance_type = "t2.micro"
	count = 1
	subnet_id = "subnet-5524d83e"
	tags = {
		name = "Albinstance"
	}
} 

resource "aws_security_group" "My-alb-sg" {
  name   = "My-albg"
  vpc_id = "vpc-6b4b9c00"
}
resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.My-alb-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.My-alb-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.My-alb-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
