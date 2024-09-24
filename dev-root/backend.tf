terraform {
  backend "s3" {
    bucket         = "iccs-remote-state"
    key            = "backend/state/iccs.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "iccs-state-lock"
  }
}