# Policy on untagged image


# resource "aws_ecr_lifecycle_policy" "untagged_image_policy" {
#   repository = aws_ecr_repository.ECR.name

#  policy = jsonencode ({

#     rules = [
#         {
#             rulePriority = 1,
#             description = "Expire images older than 14 days"
#             selection = {
#                 tagStatus = "untagged"
#                 countType = "sinceImagePushed"
#                 countUnit = "days"
#                 countNumber = 2
#             }
#             action = {
#                 type= "expire"
#             }
#         }
#     ]
#  })

# }

# Policy on tagged image

resource "aws_ecr_lifecycle_policy" "tagged_image_policy" {
  repository = aws_ecr_repository.ECR.name

  count = length(distinct(var.image_tags))

    policy = jsonencode({
    rules = [
      for i in range(length(distinct(var.image_tags))) : {
        rulePriority = i + 1
        description  = "Keep last 30 images for tag ${element(distinct(var.image_tags), i)}"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = [element(distinct(var.image_tags), i)]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
      }
      }
    ]
  })
}
