resource "random_id" "storage_account" {
  byte_length = 8
}

resource "aws_s3_bucket" "container" {
  bucket = var.container_name
  acl    = "private"

  tags = {
    Name        = "Harbor Deployment Bucket"
    Environment = "ecosystem-ci"
  }
}
