variable "OAuth" {}

resource "random_uuid" "lambda" {}

resource "aws_codepipeline" "codepipeline" {
  name     = "tasty-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "tasty-api"
        Repo       = "tasty-mock-server"
        Branch     = "master",
        OAuthToken = var.OAuth
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "tasty-mock-server"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "CFReplaceOnFailure"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = "1"

      configuration = {
        ActionMode    = "REPLACE_ON_FAILURE"
        StackName     = "tasty-mock-server"
        RoleArn       = "${aws_iam_role.cf_role.arn}"
        Capabilities  = "CAPABILITY_AUTO_EXPAND"
        TemplatePath  = "build_output::sam.yml"
      }
    }

    action {
      name            = "CFReplaceChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = "2"

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        StackName     = "tasty-mock-server"
        ChangeSetName = "tasty-mock-server-change-set"
        RoleArn       = "${aws_iam_role.cf_role.arn}"
        Capabilities  = "CAPABILITY_AUTO_EXPAND"
        TemplatePath  = "build_output::sam.yml"
      }
    }

    action {
      name            = "CFExecuteChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = "3"

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        StackName     = "tasty-mock-server"
        ChangeSetName = "tasty-mock-server-change-set"
        RoleArn       = "${aws_iam_role.cf_role.arn}"
      }
    }
  }
}

resource "aws_codebuild_project" "codebuild" {
  name          = "tasty-mock-server"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = templatefile("${path.module}/buildspec.yml", {
                        id:     "${random_uuid.lambda.result}",
                        role:   "${aws_iam_role.lambda_role.arn}",
                        bucket: "${aws_s3_bucket.codepipeline_bucket.id}"
                      })
    }
}
