terraform {
    backend "s3" {
        bucket = "sohila-tf-backend-state-unique"
        key    = "terraform.tfstate"
        region = "us-east-1"
    }
}

resource "aws_s3_bucket" "depi-project" {
    bucket = "depi-gp-project-001"
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
    bucket = aws_s3_bucket.depi-project.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
    bucket = aws_s3_bucket.depi-project.bucket
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}