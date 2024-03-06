

resource "aws_iam_role" "eks_cluster" {
  name = "-${var.Environment}"

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


#attach policies to EKS CLUSTER
resource "aws_iam_role_policy_attachment" "" {
  policy_arn = "arn:aws:iam::aws:policy/"
  role = aws_iam_role..name
}

resource "aws_iam_role_policy_attachment" "" {
  policy_arn = "arn:aws:iam::aws:policy/"
  role = aws_iam_role..name
}
#attach policies end here

