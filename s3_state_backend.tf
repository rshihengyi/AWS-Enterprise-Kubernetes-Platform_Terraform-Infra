terraform {
    backend "s3" {
        bucket = "enterprise-kubernetes-platform-tf-state"
        key = "dev/terraform.tfstate"
        region = "us-east-1"
    }
}