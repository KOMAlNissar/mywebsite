#################################
# Provider
#################################
provider "aws" {
  region = "us-east-1"
}

#################################
# Generate unique bucket suffix
#################################
resource "random_id" "bucket_id" {
  byte_length = 4
}

#################################
# Create S3 bucket
#################################
resource "aws_s3_bucket" "website_bucket" {
  bucket = "terraform-site-komal-${random_id.bucket_id.hex}"
}

#################################
# Disable Block Public Access
#################################
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#################################
# Bucket policy (public read)
#################################
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

#################################
# Enable static website hosting
#################################
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#################################
# Upload index.html
#################################
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"

  content = <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Terraform Website</title>
  <style>
    body { margin:0; font-family:Arial, sans-serif; background:linear-gradient(to right,#74ebd5,#ACB6E5); color:#333; }
    nav{padding:20px;background:rgba(0,0,0,0.3);color:white;text-align:center;}
    h1{margin-top:100px;text-align:center;color:white;}
    p{text-align:center;color:white;font-size:1.2em;}
    footer{position:fixed;bottom:0;width:100%;text-align:center;background:rgba(0,0,0,0.3);color:white;padding:10px;}
  </style>
</head>
<body>
  <nav><h2>Terraform S3 Website</h2></nav>
  <h1>Welcome 🎉</h1>
  <p>Your static website is successfully deployed using Terraform.</p>
  <footer>© 2025 Komal | Terraform + AWS</footer>
</body>
</html>
HTML

  content_type = "text/html"
}

#################################
# Upload error.html
#################################
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "error.html"

  content      = "<h1>Oops! Page not found.</h1>"
  content_type = "text/html"
}

#################################
# Output website URL
#################################
output "website_url" {
  description = "Live S3 static website URL"
  value       = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website-us-east-1.amazonaws.com"
}
