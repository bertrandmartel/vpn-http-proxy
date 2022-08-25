output "policy_server" {
  description = "IAM policy for accessing secret on server"
  value       = aws_iam_policy.instance_policy_secret_server
}

output "aws_ssm_association" {
  value = aws_ssm_association.ssm_assoc
}

output "aws_ssm_document" {
  value = aws_ssm_document.ssm_doc
}