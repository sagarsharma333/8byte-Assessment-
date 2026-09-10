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

######### DLM Lifecycle Policy for ami Snapshots #########

resource "aws_iam_role" "DLM" {
    name = "${var.project_name}-DLM-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "dlm.amazonaws.com"
                }
            },
        ]
    })
  
}
resource "aws_iam_role_policy_attachment" "DLM" {
    role       = aws_iam_role.DLM.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole" #aws managed policy for DLM
}


resource "aws_dlm_lifecycle_policy" "ami_snapshot_policy" {
    description = "DLM Lifecycle Policy for AMI Snapshots"
    execution_role_arn = aws_iam_role.DLM.arn
    state = "ENABLED"
    policy_details {
        resource_types = ["INSTANCE"]
        policy_type = "IMAGE_MANAGEMENT"
        #targetting a tag instead of a specific instance id fo reusability 
        target_tags = {
            "Environment" = "dev,prod&stg"
        }

        schedule {
            name = "DailyAMISnapshotSchedule"
            create_rule {
                cron_expression = "cron(0 2 1 * ? *)" #every 1st day of the month at 2 AM UTC
            }
            retain_rule {
                count = 1 # you want 2 or more for real environments
            }
        }
    }
}