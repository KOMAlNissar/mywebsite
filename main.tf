provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-terraform-static-website-12345"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  content = "<h1>Hello from Terraform</h1>"
  content_type = "text/html"
}
