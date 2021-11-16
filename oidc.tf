data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "external" "thumbprint" {
  program = ["${path.module}/oidc_thumbprint.sh", var.region]
}

resource "aws_iam_openid_connect_provider" "default" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = var.tags

  depends_on = [
    data.external.thumbprint
  ]
}