locals {
  project_root = "${path.module}/.."

  manifest_vars = {
    acr_login_server          = azurerm_container_registry.acr.login_server
    storage_connection_string = azurerm_storage_account.storage_account.primary_connection_string
    student_container         = azurerm_storage_container.student_profile_photo.name
    lecturer_container        = azurerm_storage_container.lecturer_profile_photo.name
    image_tag                 = var.image_tag
  }
}

# Non-sensitive manifests
resource "local_file" "kubernetes_manifests" {
  for_each = fileset("${path.module}/templates/kubernetes", "*.tftpl")

  filename = "${local.project_root}/kubernetes/${trimsuffix(each.value, ".tftpl")}"
  content = templatefile(
    "${path.module}/templates/kubernetes/${each.value}",
    local.manifest_vars
  )
  file_permission = "0644"
}

# Secret manifest, written with restricted permissions and kept out of the plan output
resource "local_sensitive_file" "application_secret" {
  filename = "${local.project_root}/kubernetes/07-application-secret.yaml"
  content = templatefile(
    "${path.module}/templates/secrets/07-application-secret.yaml.tftpl",
    local.manifest_vars
  )
  file_permission = "0600"
}

# Per-service .env files
resource "local_sensitive_file" "service_env" {
  for_each = {
    student-service  = azurerm_storage_container.student_profile_photo.name
    lecturer-service = azurerm_storage_container.lecturer_profile_photo.name
  }

  filename = "${local.project_root}/${each.key}/.env"
  content = templatefile("${path.module}/templates/env/service.env.tftpl", {
    storage_connection_string = azurerm_storage_account.storage_account.primary_connection_string
    container_name            = each.value
  })
  file_permission = "0600"
}
resource "local_file" "build_and_push" {
  filename = "${local.project_root}/build-and-push.ps1"
  content = templatefile("${path.module}/templates/build-and-push.ps1.tftpl", {
    acr_name         = azurerm_container_registry.acr.name
    acr_login_server = azurerm_container_registry.acr.login_server
    image_tag        = var.image_tag
  })
  file_permission = "0755"
}