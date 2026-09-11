terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket       = "jays-07092026-875285643708"
    key          = "excercise/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}