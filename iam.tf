// IAM role for EKS worker nodes

/* Minimum Parameters: 
    - name:                 role name
    - assume_role_policy:   trust policy (who can wear the hat)
*/
resource "aws_iam_role" "lb_controller" {
  name = "Load-Balance-Controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

/* Minimum Parameters: 
    - role:                 what role to attach permissions to
    - policy_arn:           the iam policy arn
*/
resource "aws_iam_role_policy_attachment" "controller_pa" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.controller_permissions.arn
}


/* Minimum Parameters: 
    - name:                 custom name for policy list
    - policy:               (list of permissions to allow for whoever wears the hat)
*/
// Source: https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEKSWorkerNodePolicy.html
resource "aws_iam_policy" "controller_permissions" {
  name = "Controller-Permissions-List"
  // AmazonEKSLoadBalancingPolicy 
  policy = jsonencode(
    {

      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateRule",
            "ec2:CreateSecurityGroup"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/eks:eks-cluster-name" : "${module.eks.cluster_name}"
            },
            "ForAllValues:StringEquals" : {
              "aws:TagKeys" : [
                "eks:eks-cluster-name",
                "ingress.eks.amazonaws.com/stack",
                "ingress.eks.amazonaws.com/resource",
                "service.eks.amazonaws.com/stack",
                "service.eks.amazonaws.com/resource"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateSecurityGroup"
          ],
          "Resource" : "arn:aws:ec2:*:*:vpc/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:RegisterTargets"
          ],
          "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:AuthorizeSecurityGroupIngress"
          ],
          "Resource" : "arn:aws:ec2:*:*:security-group-rule/*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/eks:eks-cluster-name" : "${module.eks.cluster_name}"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress"
          ],
          "Resource" : "arn:aws:ec2:*:*:security-group/*",
          "Condition" : {
            "StringLike" : {
              "aws:ResourceTag/Name" : "eks-cluster-sg*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress"
          ],
          "Resource" : "arn:aws:ec2:*:*:security-group/*",
          "Condition" : {
            "StringEquals" : {
              "aws:ResourceTag/eks:eks-cluster-name" : "${module.eks.cluster_name}"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:AddTags"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "elasticloadbalancing:CreateAction" : [
                "CreateLoadBalancer",
                "CreateTargetGroup",
                "CreateListener",
                "CreateRule"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "ec2:CreateAction" : [
                "CreateSecurityGroup",
                "AuthorizeSecurityGroupIngress"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:ModifyListenerAttributes",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:ModifyIpPools",
            "elasticloadbalancing:ModifyCapacityReservation",
            "elasticloadbalancing:DescribeLoadBalancers"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:ResourceTag/eks:eks-cluster-name" : "${module.eks.cluster_name}"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "wafv2:AssociateWebACL",
            "wafv2:DisassociateWebACL"
          ],
          "Resource" : [
            "arn:aws:wafv2:*:*:*/webacl/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "shield:CreateProtection",
            "shield:DeleteProtection"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "shield:TagResource"
          ],
          "Resource" : "arn:aws:shield::*:protection/*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestTag/eks:eks-cluster-name" : "${module.eks.cluster_name}"
            },
            "ForAllValues:StringEquals" : {
              "aws:TagKeys" : [
                "eks:eks-cluster-name",
                "ingress.eks.amazonaws.com/stack",
                "ingress.eks.amazonaws.com/resource",
                "service.eks.amazonaws.com/stack",
                "service.eks.amazonaws.com/resource"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "cognito-idp:DescribeUserPoolClient",
            "acm:ListCertificates",
            "acm:DescribeCertificate",
            "wafv2:GetWebACL",
            "wafv2:GetWebACLForResource",
            "elasticloadbalancing:SetWebAcl",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:SetRulePriorities"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcClassicLink",
            "ec2:DescribeInstances",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeClassicLinkInstances",
            "ec2:DescribeRouteTables",
            "ec2:DescribeCoipPools",
            "ec2:GetCoipPoolUsage",
            "ec2:GetSecurityGroupsForVpc",
            "ec2:DescribeVpcPeeringConnections",
            "ec2:DescribeIpamPools"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateServiceLinkedRole"
          ],
          "Resource" : "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
            }
          }
        }
      ]


    }
  )


}

/* IAM role for Worker Nodes
    - Allow EKS Pod Identity Agent to ask for temp credentials to AWS
*/
resource "aws_iam_role" "worker_node_IAM_role" {
  name = "EKS-Worker-Node-IAM-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_pa" {
  role       = aws_iam_role.worker_node_IAM_role.name
  policy_arn = aws_iam_policy.worker_node_permissions.arn
}

resource "aws_iam_policy" "worker_node_permissions" {
  name = "worker-node-permissions"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "eks-auth:AssumeRoleForPodIdentity"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}