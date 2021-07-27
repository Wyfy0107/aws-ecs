resource "aws_iam_role" "task_role" {
  name = "ecs-task"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_logs_role" {
  name = "task-logs"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

# data "aws_iam_policy_document" "task_logs_policy" {

#   statement {
#     effect = "Allow"

#     actions = [
#       "cloudwatch:*",
#     ]

#     resources = [
#       "*"
#     ]
#   }
# }

resource "aws_iam_policy" "ecs_logs" {
  name = "ecs-logs"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:*"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "task_logs_attachment" {
  role       = aws_iam_role.task_logs_role.name
  policy_arn = aws_iam_policy.ecs_logs.arn
}
