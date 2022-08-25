output "kms" {
  description = "KMS key for S3"
  value       = aws_kms_key.kms_s3
}
output "bucket_playbook" {
  description = "Ansible playbook s3 bucket"
  value       = aws_s3_bucket.playbook_bucket
}
output "playbook_files" {
  description = "s3 bucket playbook files object"
  value       = aws_s3_bucket_object.playbook_files
}
output "policy" {
  value = aws_iam_policy.s3_policy
}
