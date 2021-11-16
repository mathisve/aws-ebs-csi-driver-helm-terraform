resource "helm_release" "ebs-csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  namespace = "kube-system"

  values = [
    "${file("${path.module}/ebs-csi.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${lookup(var.container_image_address_region_map, var.region, "")}eks/aws-ebs-csi-driver"
  }

  provisioner "local-exec" {
    command = <<EOF
            kubectl annotate serviceaccount ebs-csi-controller-sa \
            -n kube-system \
            eks.amazonaws.com/role-arn=${aws_iam_role.ebs_csi_driver.arn}
        EOF
  }
}