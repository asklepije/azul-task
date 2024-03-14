
resource "aws_s3_bucket" "bucket" {
  bucket = "asklepijes.com"
  acl    = "private"
  tags = {
    Name = "task-bucket"
  }
  force_destroy = true

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_object" "data_dir" {
  bucket = aws_s3_bucket.bucket.id
  key    = "data/"

}
resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}
