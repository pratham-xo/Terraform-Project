resource "aws_ecs_cluster" "ecs_cluster" {
   name = "ecs_cluster"
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement ={
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
    }
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [var.alb_security_group]
  }  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix = "ecs_launch_template"
  image_id = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.ecs_sg.id ]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }
  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
EOF
)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-ec2-instance"
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity = 3
  max_size = 3
  min_size = 2

  vpc_zone_identifier = [ 
    var.private_subnet,
    var.private_subnet2
   ]
   launch_template {
     id = aws_launch_template.ecs_launch_template.id
     version = "$Latest"
   }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "demo_capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [ 
    aws_ecs_capacity_provider.ecs_capacity_provider.name
   ]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight = 1
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = "nginx-task"
  network_mode = "bridge"
  requires_compatibilities = [ "EC2" ]
  cpu = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      name = "nginx"
      image = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "name" {
  name = "nginx-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count = 1
  launch_type = "EC2"
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = "nginx"
    container_port = 80
  }
  depends_on = [ aws_ecs_cluster_capacity_providers.cluster_capacity_provider ]
}





