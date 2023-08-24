output "vm01_public_ip" {
  value = aws_instance.vm01_public.public_ip
}

output "vm02_private" {
  value = aws_instance.vm02_private.private_ip
}

output "vm03_private" {
  value = aws_instance.vm03_private.private_ip
}
