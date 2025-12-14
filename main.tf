provider "aws" {
  region = "us-east-1"
}

# 1️⃣ Create S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-terraform-static-website-12345"
}

# 2️⃣ Bucket policy for public read (required, ACLs deprecated)
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id

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

# 3️⃣ Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 4️⃣ Upload main index.html (pretty modern UI)
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  content      = <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Terraform Website</title>
  <style>
    body { margin:0; font-family:'Helvetica Neue', Arial, sans-serif; background:linear-gradient(to right,#74ebd5,#ACB6E5); color:#333; }
    a{text-decoration:none;color:inherit;}
    nav{display:flex;justify-content:space-between;align-items:center;padding:20px 50px;background:rgba(0,0,0,0.3);color:white;position:sticky;top:0;}
    nav .logo{font-size:1.8em;font-weight:bold;}
    nav .menu a{margin-left:25px;font-weight:bold;transition:color 0.3s;}
    nav .menu a:hover{color:#ffd700;}
    .hero{height:80vh;display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;color:white;padding:0 20px;}
    .hero h1{font-size:3em;margin-bottom:20px;text-shadow:2px 2px 8px rgba(0,0,0,0.3);}
    .hero p{font-size:1.5em;margin-bottom:30px;text-shadow:1px 1px 6px rgba(0,0,0,0.3);}
    .hero .btn{background:#ff7e5f;color:white;padding:15px 30px;font-size:1.2em;border:none;border-radius:50px;cursor:pointer;transition:background 0.3s;}
    .hero .btn:hover{background:#feb47b;}
    footer{background:rgba(0,0,0,0.3);color:white;text-align:center;padding:20px;}
    section{padding:50px;text-align:center;}
    @media(max-width:768px){.hero h1{font-size:2.2em;}.hero p{font-size:1.2em;}nav{flex-direction:column;}nav .menu{margin-top:10px;}}
  </style>
</head>
<body>
  <nav>
    <div class="logo">TerraformSite</div>
    <div class="menu">
      <a href="#home">Home</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
    </div>
  </nav>

  <section class="hero" id="home">
    <h1>Welcome to My Terraform Website!</h1>
    <p>Deploying modern websites with AWS S3 and Terraform.</p>
    <button class="btn">Learn More</button>
  </section>

  <section id="about">
    <h2>About This Site</h2>
    <p>This is a fully static website hosted on AWS S3, created and deployed entirely using Terraform.</p>
  </section>

  <section id="contact">
    <h2>Contact</h2>
    <p>Email: <a href="mailto:youremail@example.com">youremail@example.com</a></p>
  </section>

  <footer>© 2025 Terraform Website | Made with ❤️</footer>
</body>
</html>
HTML
  content_type = "text/html"
}

# 5️⃣ Optional error page
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "error.html"
  content      = "<h1>Oops! Page not found.</h1>"
  content_type = "text/html"
}

# 6️⃣ Terraform output for website URL
output "website_url" {
  value = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website-us-east-1.amazonaws.com"
  description = "URL of the deployed S3 website"
}

