output "id" {
  value       = aws_s3_bucket.bucket.id
  description = "Bucket name."
}

output "arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "Bucket ARN."
}
