output "instance_name" {
  description = "Nombre de la instancia creada"
  value       = google_compute_instance.budget_app.name
}

output "instance_zone" {
  description = "Zona donde se creó la instancia"
  value       = google_compute_instance.budget_app.zone
}

output "external_ip" {
  description = "Dirección IP pública de la instancia"
  value       = google_compute_instance.budget_app.network_interface[0].access_config[0].nat_ip
}

output "ssh_connection_command" {
  description = "Comando para conectarte fácilmente"
  value       = "gcloud compute ssh ${google_compute_instance.budget_app.name} --zone=${google_compute_instance.budget_app.zone}"
}
