provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

module "ecr" {
  source = "./ecr"
}
module "ecs" {
  source         = "./ecs"
  subnet_ids     = module.vpc.subnet_id
  security_group = module.vpc.security_group
  ecr_repository = module.ecr.ecr_repository
  image_version  = var.image_version
}
module "vpc" {
  source = "./vpc"
}
module "s3" {
  source = "./s3"
}
module "cloudfront" {
  source          = "./cloudfront"
  bucket_domain   = module.s3.domain_name
  certificate_arn = module.acm.certificate_arn
  bucket_id       = module.s3.bucket_id
}
module "route53" {
  source          = "./route53"
  hosted_zone     = var.hosted_zone
  cdf_domain_name = module.cloudfront.cdf_domain_name
  cdf_hosted_zone = module.cloudfront.cdf_hosted_zone
}
module "eventbridge" {
  source              = "./eventbridge"
  subnet_ids          = module.vpc.subnet_id
  security_group      = module.vpc.security_group
  task_definition_arn = module.ecs.task_definition_arn
  cluster_arn         = module.ecs.cluster_arn
}
module "acm" {
  source      = "./acm"
  hosted_zone = var.hosted_zone
  bucket_zone = module.s3.bucket_zone
}

variable "hosted_zone" {
  type    = string
  default = "Z01801181BKTEW7LHKX3K"
}
variable "image_version" {
  type = string
}
