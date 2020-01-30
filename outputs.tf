output "asg" {
  value = module.asg
}

output "sg_id" {
  description = "Id of the sg created."
  value       = module.asg.security_group_id
}
