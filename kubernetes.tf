# /*
#     Using data from state file for EKS Cluster
# */
# data "terraform_remote_state" "eks" {
#   backend = "s3"
#   config = {
#     bucket = "enterprise-kubernetes-platform-tf-state"
#     key = "dev/terraform.tfstate"
#     region = "us-east-1"
#   }
# }



# data "aws_eks_cluster" "cluster" {
#   name = data.terraform_remote_state.eks.outputs.cluster_name
# }


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}
