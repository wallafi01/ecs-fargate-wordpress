output "s3_bucket_id" {
  value = aws_s3_bucket.backend.id
}


output "s3_bucket_name" {
  value = aws_s3_bucket.backend.bucket
}