# ------------------------------------------------------------------------------
# privileges for the instance we are standing up
# ------------------------------------------------------------------------------
resource "aws_iam_role" "instance_connect" {
  count       = var.enable_bastion ? 1 : 0
  name        = "instance-connect"
  description = "privileges for the instance-connect demonstration"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com" ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "instance_connect" {
  count      = var.enable_bastion ? 1 : 0
  role       = aws_iam_role.instance_connect[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "instance_connect" {
  count = var.enable_bastion ? 1 : 0
  name  = "instance-connect"
  role  = aws_iam_role.instance_connect[0].id
}

# ------------------------------------------------------------------------------
# policy for users allowing connection
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "instance_connect" {
  count       = var.enable_bastion ? 1 : 0
  name        = "instance-connect"
  path        = "/test/"
  description = "Allows use of EC2 instance connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  		"Effect": "Allow",
  		"Action": "ec2-instance-connect:SendSSHPublicKey",
  		"Resource": "${aws_instance.instance[0].arn}",
  		"Condition": {
  			"StringEquals": { "ec2:osuser": "ec2-user" }
  		}
  	},
		{
			"Effect": "Allow",
			"Action": "ec2:DescribeInstances",
			"Resource": "*"
		}
  ]
}
EOF
}

//resource "aws_iam_policy_attachment" "instance_connect" {
//  name       = "instance-connect"
//  users      = ["${var.test_user}"]
//  policy_arn = "${aws_iam_policy.instance_connect.arn}"
//}
