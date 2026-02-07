# ═══════════════════════════════════════════════════════════════════════
# QCM5 Platform Outputs
# ═══════════════════════════════════════════════════════════════════════

output "project_id" {
  description = "Code Engine project ID"
  value       = ibm_code_engine_project.qcm5_project.project_id
}

output "api_endpoint" {
  description = "QCM5 API endpoint URL"
  value       = ibm_code_engine_app.qcm5_api.endpoint
}

output "api_internal_url" {
  description = "Internal URL for QCM5 API"
  value       = ibm_code_engine_app.qcm5_api.endpoint_internal
}

output "flash_sync_job_name" {
  description = "Flash Sync job name for manual triggering"
  value       = ibm_code_engine_job.flash_sync.name
}

output "qec_decoder_job_name" {
  description = "QEC Decoder job name"
  value       = ibm_code_engine_job.qec_decoder.name
}

output "cloudant_url" {
  description = "Cloudant database URL"
  value       = ibm_cloudant.qcm5_db.crn
}

output "event_streams_crn" {
  description = "Event Streams instance CRN"
  value       = ibm_resource_instance.event_streams.crn
}

output "dashboard_url" {
  description = "QCM5 management dashboard URL"
  value       = "https://epochcoreqcs.com/dashboard"
}

output "quantum_infrastructure" {
  description = "Quantum infrastructure summary"
  value = {
    total_qubits     = 2999
    ibm_backends     = 15
    flash_sync_hz    = 7777.77
    qec_enabled      = var.enable_qec
    consensus_agents = 52
  }
}
