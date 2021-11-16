#############################################
#
# ROLES AND POLICIES FOR EBS CSI DRIVER
#
#############################################
resource "aws_iam_policy" "eks_ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_Driver_Policy"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ec2:CreateSnapshot",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "ec2:ModifyVolume",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInstances",
            "ec2:DescribeSnapshots",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:CreateTags",
          ]
          Condition = {
            StringEquals = {
              "ec2:CreateAction" = [
                "CreateVolume",
                "CreateSnapshot",
              ]
            }
          }
          Effect = "Allow"
          Resource = [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*",
          ]
        },
        {
          Action = [
            "ec2:DeleteTags",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*",
          ]
        },
        {
          Action = [
            "ec2:CreateVolume",
          ]
          Condition = {
            StringLike = {
              "aws:RequestTag/ebs.csi.aws.com/cluster" = "true"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:CreateVolume",
          ]
          Condition = {
            StringLike = {
              "aws:RequestTag/CSIVolumeName" = "*"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:CreateVolume",
          ]
          Condition = {
            StringLike = {
              "aws:RequestTag/kubernetes.io/cluster/*" = "owned"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:DeleteVolume",
          ]
          Condition = {
            StringLike = {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:DeleteVolume",
          ]
          Condition = {
            StringLike = {
              "ec2:ResourceTag/CSIVolumeName" = "*"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:DeleteVolume",
          ]
          Condition = {
            StringLike = {
              "ec2:ResourceTag/kubernetes.io/cluster/*" = "owned"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:DeleteSnapshot",
          ]
          Condition = {
            StringLike = {
              "ec2:ResourceTag/CSIVolumeSnapshotName" = "*"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ec2:DeleteSnapshot",
          ]
          Condition = {
            StringLike = {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
            }
          }
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )

  tags = var.tags
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              replace("${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}:sub", "https://", "") = "system:serviceaccount:kube-system:ebs-csi-controller-sa",
              replace("${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}:aud", "https://", "") = "sts.amazonaws.com"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = aws_iam_openid_connect_provider.default.arn
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.eks_ebs_csi_driver.arn
  ]

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_ci_driver" {
  policy_arn = aws_iam_policy.eks_ebs_csi_driver.arn
  role       = aws_iam_role.ebs_csi_driver.name
}