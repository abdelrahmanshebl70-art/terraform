terraform {
  backend "s3" {
    bucket = "shipl-606025553589-us-east-1-an"
    key    = "shipl/key"
    region = "us-east-1"
   use_lockfile   = true
  }
}