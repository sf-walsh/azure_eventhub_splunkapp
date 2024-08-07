output "splunk_app_uuid" {
  description = "Splunk App UUID"
#   sensitive = true
  value       = azuread_application_password.splunk.key_id
}

output "splunk_app_secret" {
  description = "Splunk App Secret"
#   sensitive = true
  value       = nonsensitive(azuread_application_password.splunk.value)
}