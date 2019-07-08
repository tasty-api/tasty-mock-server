provider "aws" {
  region = "us-east-1"
  version =  "~> 2.0"
}

provider "template" {
  version =  "~> 2.0"
}

provider "random" {
  version = "~> 2.1"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "tastyjs"
  acl    = "private"
}
