output "alb-ingress-controller-policy" {
  value       = data.aws_iam_policy_document.alb-ingress-controller.json
  description = "JSON formatted string describing the IAM policies required for a ALB ingress controller."
}
