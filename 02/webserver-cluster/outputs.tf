output "myalb_dnsname" {
  description = "My ALB DNS Name"
  value       = aws_lb.myalb.dns_name
}

output "myalb_url" {
  description = "My ALB DNS URL"
  value       = "http://${aws_lb.myalb.dns_name}"
}

output "debug_vpc_id" {
  value = data.aws_vpc.default.id
}
