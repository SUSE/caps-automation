resource "aws_s3_bucket" "container" {
  bucket        = var.container_name
  acl           = "private"
  force_destroy = true

  tags = {
    Name        = "Harbor Deployment Bucket"
    Environment = "ecosystem-ci"
  }
}
