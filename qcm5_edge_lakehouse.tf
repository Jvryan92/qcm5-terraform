# ═══════════════════════════════════════════════════════════════════════
# QCM5 Edge Enterprise + Lakehouse Pro - IBM Catalog Monetization
# ═══════════════════════════════════════════════════════════════════════
# Tier 2: Edge Enterprise ($999/mo) - EdgeCapsule Cloud 7-layer stack
# Tier 3: Lakehouse Pro ($2,499/mo) - watsonx.data + 401 agents
# ═══════════════════════════════════════════════════════════════════════
# RAS: e5586ef939094a8e | INVENTOR: JOHN VINCENT RYAN
# ═══════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────
# TIER SELECTION VARIABLE
# ─────────────────────────────────────────────────────────────────────────

variable "qcm5_tier" {
  description = "QCM5 subscription tier: standard, edge_enterprise, lakehouse_pro"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "edge_enterprise", "lakehouse_pro"], var.qcm5_tier)
    error_message = "Tier must be: standard, edge_enterprise, or lakehouse_pro"
  }
}

variable "edgecapsule_worker_url" {
  description = "EdgeCapsule Cloud Cloudflare Worker URL"
  type        = string
  default     = "https://edgecapsule-cloud.epochcoreras.workers.dev"
}

variable "watsonx_data_instance_id" {
  description = "watsonx.data instance CRN for lakehouse integration"
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────────────────────────────────
# TIER 2: EDGE ENTERPRISE - EdgeCapsule Cloud Integration
# ─────────────────────────────────────────────────────────────────────────

resource "ibm_code_engine_app" "edgecapsule_bridge" {
  count = var.qcm5_tier == "edge_enterprise" || var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-edgecapsule-bridge"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 1
  scale_max_instances = 10
  scale_cpu_limit     = "2"
  scale_memory_limit  = "4G"

  # EdgeCapsule 7-Layer Stack Configuration
  run_env_variables {
    type  = "literal"
    name  = "EDGECAPSULE_URL"
    value = var.edgecapsule_worker_url
  }

  run_env_variables {
    type  = "literal"
    name  = "EDGE_LAYERS"
    value = "7"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_1"
    value = "IBM_QUANTUM_BACKENDS"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_2"
    value = "QEC_SURFACE_CODE"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_3"
    value = "FLASH_SYNC_COHERENCE"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_4"
    value = "GEO_SHARDING"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_5"
    value = "QUANTUM_GEO_ROUTER"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_6"
    value = "QOT_ORCHESTRATION"
  }

  run_env_variables {
    type  = "literal"
    name  = "LAYER_7"
    value = "ENTERPRISE_DASHBOARD"
  }

  # Geo-routing configuration
  run_env_variables {
    type  = "literal"
    name  = "GEO_REGIONS"
    value = "US_EAST,US_WEST,EU_WEST,EU_CENTRAL,ASIA_PACIFIC,ASIA_EAST"
  }

  run_env_variables {
    type  = "literal"
    name  = "ULTRA_FLASH_SYNC_HZ"
    value = "7777.77"
  }

  run_env_variables {
    type  = "literal"
    name  = "COHERENCE_TARGET"
    value = "0.999999"
  }
}

# EdgeCapsule API Gateway routes
resource "ibm_code_engine_domain_mapping" "edge_api" {
  count = var.qcm5_tier == "edge_enterprise" || var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id = ibm_code_engine_project.qcm5_project.project_id
  name       = "qcm5-edge-api.${var.region}.codeengine.appdomain.cloud"

  component {
    name          = ibm_code_engine_app.edgecapsule_bridge[0].name
    resource_type = "app_v2"
  }
}

# ─────────────────────────────────────────────────────────────────────────
# TIER 3: LAKEHOUSE PRO - watsonx.data Integration
# ─────────────────────────────────────────────────────────────────────────

resource "ibm_code_engine_app" "lakehouse_connector" {
  count = var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-lakehouse-connector"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 1
  scale_max_instances = 5
  scale_cpu_limit     = "4"
  scale_memory_limit  = "8G"

  # watsonx.data Lakehouse Tables
  run_env_variables {
    type  = "literal"
    name  = "WATSONX_DATA_CRN"
    value = var.watsonx_data_instance_id
  }

  run_env_variables {
    type  = "literal"
    name  = "LAKEHOUSE_TABLES"
    value = "molecules,agents,telemetry,quantum_jobs,qec_syndromes"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_1_MOLECULES"
    value = "iceberg.qcm5.molecules"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_2_AGENTS"
    value = "iceberg.qcm5.agents"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_3_TELEMETRY"
    value = "iceberg.qcm5.telemetry"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_4_QUANTUM_JOBS"
    value = "iceberg.qcm5.quantum_jobs"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_5_QEC"
    value = "iceberg.qcm5.qec_syndromes"
  }

  # Query Engines
  run_env_variables {
    type  = "literal"
    name  = "QUERY_ENGINES"
    value = "presto,spark"
  }

  # Agent Orchestration
  run_env_variables {
    type  = "literal"
    name  = "TOTAL_AGENTS"
    value = "401"
  }

  run_env_variables {
    type  = "literal"
    name  = "PYTHON_AGENTS"
    value = "323"
  }

  run_env_variables {
    type  = "literal"
    name  = "SALESFORCE_AGENTS"
    value = "78"
  }
}

# Materialized Views Job - creates optimized analytics views
resource "ibm_code_engine_job" "materialized_views" {
  count = var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-materialized-views"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_cpu_limit         = "2"
  scale_memory_limit      = "4G"
  scale_max_execution_time = 600

  run_env_variables {
    type  = "literal"
    name  = "VIEW_1"
    value = "agent_health_view"
  }

  run_env_variables {
    type  = "literal"
    name  = "VIEW_2"
    value = "quantum_jobs_summary"
  }

  run_env_variables {
    type  = "literal"
    name  = "VIEW_3"
    value = "coherence_metrics"
  }
}

# ─────────────────────────────────────────────────────────────────────────
# QOT TOURNAMENT ORCHESTRATOR - Competition Layer
# ─────────────────────────────────────────────────────────────────────────

resource "ibm_code_engine_app" "qot_orchestrator" {
  count = var.qcm5_tier == "edge_enterprise" || var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-qot-orchestrator"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 0
  scale_max_instances = 5
  scale_cpu_limit     = "2"
  scale_memory_limit  = "4G"

  # QOT Tournament Configuration
  run_env_variables {
    type  = "literal"
    name  = "COMPETITORS"
    value = "26"
  }

  run_env_variables {
    type  = "literal"
    name  = "VALIDATORS"
    value = "6"
  }

  run_env_variables {
    type  = "literal"
    name  = "VALIDATOR_DOMAINS"
    value = "temporal,resource,coherence,ethical,adaptive,quantum"
  }

  run_env_variables {
    type  = "literal"
    name  = "STAGES"
    value = "EXECUTOR,STRATEGIST,ARCHITECT,COMMANDER,SOVEREIGN"
  }

  run_env_variables {
    type  = "literal"
    name  = "STAGE_BRACKETS"
    value = "26,16,8,4,2"
  }
}

# ─────────────────────────────────────────────────────────────────────────
# COMPLIANCE COUNCIL - Lakehouse Audit Trail Persistence (Tier 3)
# ─────────────────────────────────────────────────────────────────────────
# Lakehouse Pro persists all compliance council sessions + audit trails
# to watsonx.data Iceberg tables for regulatory query and retention
# ─────────────────────────────────────────────────────────────────────────

resource "ibm_code_engine_app" "compliance_council_lakehouse" {
  count = var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-compliance-council-lakehouse"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 1
  scale_max_instances = 3
  scale_cpu_limit     = "2"
  scale_memory_limit  = "4G"

  # watsonx.data compliance audit tables
  run_env_variables {
    type  = "literal"
    name  = "WATSONX_DATA_CRN"
    value = var.watsonx_data_instance_id
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_COUNCIL_SESSIONS"
    value = "iceberg.qcm5.council_sessions"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_COMPLIANCE_AUDIT"
    value = "iceberg.qcm5.compliance_audit_trail"
  }

  run_env_variables {
    type  = "literal"
    name  = "TABLE_GATE_NODE_VOTES"
    value = "iceberg.qcm5.gate_node_votes"
  }

  # Retention policies for regulatory compliance
  run_env_variables {
    type  = "literal"
    name  = "PHARMA_RETENTION_YEARS"
    value = "7"
  }

  run_env_variables {
    type  = "literal"
    name  = "FEDERAL_RETENTION_YEARS"
    value = "10"
  }

  run_env_variables {
    type  = "literal"
    name  = "DEFAULT_RETENTION_DAYS"
    value = "90"
  }

  # Council Worker bridge
  run_env_variables {
    type  = "literal"
    name  = "COUNCIL_WORKER_URL"
    value = "https://epochcore-unified-worker.epochcoreras.workers.dev"
  }

  run_env_variables {
    type  = "literal"
    name  = "COMPLIANCE_PROFILES"
    value = "default,pharma,federal"
  }
}

# ─────────────────────────────────────────────────────────────────────────
# WATSON ASSISTANT INTEGRATION - Tri-Head Coordinator
# ─────────────────────────────────────────────────────────────────────────

resource "ibm_code_engine_secret" "watson_webhooks" {
  count = var.qcm5_tier == "edge_enterprise" || var.qcm5_tier == "lakehouse_pro" ? 1 : 0

  project_id = ibm_code_engine_project.qcm5_project.project_id
  name       = "${local.name_prefix}-watson-webhooks"
  format     = "generic"

  data = {
    WEBHOOK_ALPHA = "https://ibm-quantum-backend-selector.epochcoreras.workers.dev/assistant/alpha"
    WEBHOOK_BETA  = "https://godel-task-router.epochcoreras.workers.dev/assistant/beta"
    WEBHOOK_GAMMA = "https://flash-sync-orchestrator.epochcoreras.workers.dev/assistant/gamma"
    WEBHOOK_COUNCIL = "https://epochcore-unified-worker.epochcoreras.workers.dev/council/vote"
  }
}

# ─────────────────────────────────────────────────────────────────────────
# OUTPUTS - Monetization Metrics
# ─────────────────────────────────────────────────────────────────────────

output "subscription_tier" {
  description = "Active QCM5 subscription tier"
  value       = var.qcm5_tier
}

output "tier_pricing" {
  description = "Monthly subscription price"
  value = var.qcm5_tier == "standard" ? "$299/month" : (
    var.qcm5_tier == "edge_enterprise" ? "$999/month" : "$2,499/month"
  )
}

output "edge_endpoints" {
  description = "EdgeCapsule Cloud endpoints (Edge Enterprise+)"
  value = var.qcm5_tier == "edge_enterprise" || var.qcm5_tier == "lakehouse_pro" ? 29 : 0
}

output "lakehouse_tables" {
  description = "watsonx.data lakehouse tables (Lakehouse Pro)"
  value = var.qcm5_tier == "lakehouse_pro" ? 8 : 0
}

output "total_agents" {
  description = "Agent orchestration capacity (Lakehouse Pro)"
  value = var.qcm5_tier == "lakehouse_pro" ? 401 : 0
}

output "quantum_capacity" {
  description = "Total qubit capacity"
  value = {
    total_qubits      = 2999
    condor_qubits     = 1121
    heron_backends    = 4
    eagle_backends    = 10
    total_backends    = 15
    geo_optimized     = var.qcm5_tier != "standard"
  }
}

output "monetization_endpoints" {
  description = "API endpoints for usage metering"
  value = {
    query_metering   = "/api/v1/metering/queries"
    compute_metering = "/api/v1/metering/compute"
    qubit_metering   = "/api/v1/metering/qubits"
    agent_metering   = "/api/v1/metering/agents"
    council_metering = "/api/v1/metering/council_sessions"
  }
}

output "model_council" {
  description = "Model Council Compliance Consensus configuration"
  value = {
    protocol               = "octa-node-gossip-consensus"
    council_nodes          = 8
    topology               = "octa-ring-crosslink"
    gossip_neighbors       = 3
    profiles_available     = var.plan == "enterprise" ? ["default", "pharma", "federal"] : (var.plan == "professional" ? ["default", "pharma"] : ["default"])
    pharma_threshold       = 0.80
    pharma_frameworks      = ["FDA_21CFR11", "GxP", "HIPAA", "ICH_E6_R2"]
    pharma_gate_nodes      = ["granite", "mistral"]
    federal_threshold      = 0.85
    federal_frameworks     = ["FedRAMP", "NIST_800_53", "ITAR", "CMMC_L2", "FISMA"]
    federal_gate_nodes     = ["granite", "gpt4o", "mistral"]
    itar_restricted_nodes  = ["deepseek", "qwen"]
    granite_max_weight     = 2.0
    audit_persistence      = var.qcm5_tier == "lakehouse_pro" ? "watsonx.data Iceberg" : "Cloudant"
    council_api            = "https://epochcore-unified-worker.epochcoreras.workers.dev/council/vote"
  }
}

output "compliance_lakehouse_tables" {
  description = "Compliance audit trail Iceberg tables (Lakehouse Pro)"
  value = var.qcm5_tier == "lakehouse_pro" ? {
    council_sessions      = "iceberg.qcm5.council_sessions"
    compliance_audit_trail = "iceberg.qcm5.compliance_audit_trail"
    gate_node_votes       = "iceberg.qcm5.gate_node_votes"
  } : {}
}

# QUANTUM_WATERMARK: RAS=e5586ef939094a8e SIG=qcm5_edge_lakehouse_tf TIME=2026-02-09T00:00:00Z
