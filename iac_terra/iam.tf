resource "aws_iam_role" "cloudwatch" {
    name = "${var.project_name}-cloudwatch-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
  
}
resource "aws_iam_role_policy_attachment" "cloudwatch" {
    role       = aws_iam_role.cloudwatch.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" #attached my cloudwatch policy to the role above
}
resource "aws_iam_instance_profile" "cloudwatch" {
    name = "${var.project_name}-cloudwatch-instance-profile"            
    role = aws_iam_role.cloudwatch.name                               # then attached it to the ec2 instance in ec2.tf
}