output "server" {
  description = "The IPA server EC2 instance."
  value       = aws_instance.ipa
}
