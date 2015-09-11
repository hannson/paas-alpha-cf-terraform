resource "aws_elb" "router" {
  name = "${var.env}-cf-router-elb"
  subnets = ["${aws_subnet.public.*.id}"]
  security_groups = [
    "${aws_security_group.web.id}",
  ]

  health_check {
    target = "TCP:443"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }
  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 4443
    lb_protocol = "tcp"
  }
}

resource "aws_security_group" "router" {
  name = "${var.env}-router"
  description = "Router security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [
      "${aws_security_group.web.id}"
    ]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [
      "${aws_security_group.web.id}"
    ]
  }

  tags = {
    Name = "${var.env}-cf-router"
  }
}