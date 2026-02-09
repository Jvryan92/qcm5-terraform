# QCM5 Platform Outputs

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
    model_council    = true
    council_nodes    = 8
  }
}

output "model_council_endpoint" {
  description = "Model Council API endpoint URL"
  value       = ibm_code_engine_app.model_council.endpoint
}

output "council_databases" {
  description = "Council + compliance audit Cloudant databases"
  value = {
    sessions    = ibm_cloudant_database.council_sessions.db
    audit_trail = ibm_cloudant_database.compliance_audit_trail.db
  }
}

output "compliance_profiles" {
  description = "Available compliance council profiles by plan"
  value = var.plan == "enterprise" ? "default, pharma, federal" : (var.plan == "professional" ? "default, pharma" : "default")
}

output "dispatch_controller" {
  description = "Dispatch namespace controller with tier routing"
  value = {
    endpoint       = var.dispatch_endpoint
    namespace      = "staging"
    tiers          = ["standard ($299/mo)", "edge ($999/mo)", "lakehouse ($2,499/mo)"]
    synthesis      = var.synthesis_endpoint
    council        = var.council_worker_url
    mcp_servers    = 12
    council_nodes  = 8
  }
}

output "optimization_metrics" {
  description = "Swarm optimization compound metrics"
  value = {
    tranches_complete   = 5
    total_steps         = 50
    final_compound      = 119728.3
    phi                 = 1.618033988749895
    flash_sync_hz       = 7777.77
    num_profiles        = 3
    caches_active       = 3
  }
}
