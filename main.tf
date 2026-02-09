terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════
# QCM5 Quantum Error Correction Platform - Production Deployment
# ═══════════════════════════════════════════════════════════════════════
# 2,999 qubits across 15 IBM Quantum backends
# 52-Agent Consensus Routing | 7777.77 Hz Flash Sync | QEC Surface Codes
# ═══════════════════════════════════════════════════════════════════════

provider "ibm" {
  region = var.region
}

# ═══════════════════════════════════════════════════════════════════════
# RESOURCE GROUP - Use provided or lookup Default
# ═══════════════════════════════════════════════════════════════════════

data "ibm_resource_group" "default" {
  count    = var.resource_group_id == "" ? 1 : 0
  is_default = true
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  resource_group_id = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.default[0].id
  service_plan      = var.plan == "free" ? "lite" : "standard"
  name_prefix       = "${var.instance_name}-${random_string.suffix.result}"
}

# ═══════════════════════════════════════════════════════════════════════
# CODE ENGINE PROJECT - Serverless QCM5 Platform
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_code_engine_project" "qcm5_project" {
  name              = "${local.name_prefix}-project"
  resource_group_id = local.resource_group_id
}

# QCM5 API Application - Placeholder (swap image when custom built)
resource "ibm_code_engine_app" "qcm5_api" {
  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-api"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 0
  scale_max_instances = 3
  scale_cpu_limit     = "1"
  scale_memory_limit  = "2G"

  run_env_variables {
    type  = "literal"
    name  = "QCM5_MODE"
    value = "production"
  }

  run_env_variables {
    type  = "literal"
    name  = "TOTAL_QUBITS"
    value = "2999"
  }

  run_env_variables {
    type  = "literal"
    name  = "FLASH_SYNC_HZ"
    value = "7777.77"
  }
}

# Flash Sync Cron Job - 26-node A-Z matrix synchronization
resource "ibm_code_engine_job" "flash_sync" {
  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-flash-sync"
  image_reference = "icr.io/codeengine/helloworld:latest"  # Placeholder until custom image built

  scale_cpu_limit    = "1"
  scale_memory_limit = "2G"
  scale_max_execution_time = 300

  run_env_variables {
    type  = "literal"
    name  = "SYNC_MODE"
    value = "trinity"
  }

  run_env_variables {
    type  = "literal"
    name  = "NODE_COUNT"
    value = "26"
  }

  run_env_variables {
    type  = "literal"
    name  = "CASCADE_DEPTH"
    value = "3"
  }
}

# QEC Decoder Job - Surface code error correction
resource "ibm_code_engine_job" "qec_decoder" {
  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-qec-decoder"
  image_reference = "icr.io/codeengine/helloworld:latest"  # Placeholder until custom image built

  scale_cpu_limit    = "4"
  scale_memory_limit = "8G"
  scale_max_execution_time = 600

  run_env_variables {
    type  = "literal"
    name  = "QEC_CODE"
    value = "surface_code"
  }

  run_env_variables {
    type  = "literal"
    name  = "DECODER"
    value = "nv-qldpc-decoder"
  }
}

# ═══════════════════════════════════════════════════════════════════════
# MODEL COUNCIL - Octa-Node Gossip Consensus + Compliance Profiles
# ═══════════════════════════════════════════════════════════════════════
# 8-node Bayesian gossip consensus (Opus, Granite, Llama, GPT-4o,
# Gemini, Mistral, DeepSeek, Qwen) with profile-weighted thresholds
# Profiles: default (75%), pharma (80% FDA/GxP), federal (85% ITAR)
# Gate nodes enforce regulatory approval before consensus passes
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_code_engine_app" "model_council" {
  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${local.name_prefix}-model-council"
  image_reference = "icr.io/codeengine/helloworld:latest"

  scale_min_instances = 0
  scale_max_instances = 5
  scale_cpu_limit     = "2"
  scale_memory_limit  = "4G"

  # Council Protocol
  run_env_variables {
    type  = "literal"
    name  = "COUNCIL_PROTOCOL"
    value = "octa-node-gossip-consensus"
  }

  run_env_variables {
    type  = "literal"
    name  = "COUNCIL_NODES"
    value = "opus,granite,llama,gpt4o,gemini,mistral,deepseek,qwen"
  }

  run_env_variables {
    type  = "literal"
    name  = "TOPOLOGY"
    value = "octa-ring-crosslink"
  }

  run_env_variables {
    type  = "literal"
    name  = "GOSSIP_NEIGHBORS_PER_NODE"
    value = "3"
  }

  # Profile availability gated by plan tier
  run_env_variables {
    type  = "literal"
    name  = "COMPLIANCE_PROFILES"
    value = var.plan == "enterprise" ? "default,pharma,federal" : (var.plan == "professional" ? "default,pharma" : "default")
  }

  # Pharma: FDA 21 CFR Part 11, GxP, HIPAA, ICH E6(R2) GCP
  run_env_variables {
    type  = "literal"
    name  = "PHARMA_FRAMEWORKS"
    value = "FDA_21CFR11,GxP,HIPAA,ICH_E6_R2"
  }

  run_env_variables {
    type  = "literal"
    name  = "PHARMA_THRESHOLD"
    value = "0.80"
  }

  run_env_variables {
    type  = "literal"
    name  = "PHARMA_GATE_NODES"
    value = "granite,mistral"
  }

  run_env_variables {
    type  = "literal"
    name  = "GRANITE_PHARMA_WEIGHT"
    value = "1.8"
  }

  # Federal: FedRAMP, NIST 800-53, ITAR, CMMC L2, FISMA
  run_env_variables {
    type  = "literal"
    name  = "FEDERAL_FRAMEWORKS"
    value = "FedRAMP,NIST_800_53,ITAR,CMMC_L2,FISMA"
  }

  run_env_variables {
    type  = "literal"
    name  = "FEDERAL_THRESHOLD"
    value = "0.85"
  }

  run_env_variables {
    type  = "literal"
    name  = "FEDERAL_GATE_NODES"
    value = "granite,gpt4o,mistral"
  }

  run_env_variables {
    type  = "literal"
    name  = "GRANITE_FEDERAL_WEIGHT"
    value = "2.0"
  }

  # ITAR-restricted node demotion
  run_env_variables {
    type  = "literal"
    name  = "ITAR_RESTRICTED_NODES"
    value = "deepseek,qwen"
  }

  run_env_variables {
    type  = "literal"
    name  = "ITAR_RESTRICTED_WEIGHT"
    value = "0.5"
  }

  # Live Cloudflare Worker bridge
  run_env_variables {
    type  = "literal"
    name  = "COUNCIL_WORKER_URL"
    value = var.council_worker_url
  }

  run_env_variables {
    type  = "literal"
    name  = "FLASH_SYNC_HZ"
    value = "7777.77"
  }
}

# ═══════════════════════════════════════════════════════════════════════
# CLOUDANT - Council Audit Trail Databases (Compliance Persistence)
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_cloudant_database" "council_sessions" {
  instance_crn  = ibm_cloudant.qcm5_db.crn
  db            = "council_sessions"
  partitioned   = false
}

resource "ibm_cloudant_database" "compliance_audit_trail" {
  instance_crn  = ibm_cloudant.qcm5_db.crn
  db            = "compliance_audit_trail"
  partitioned   = true
}

# ═══════════════════════════════════════════════════════════════════════
# SECRETS MANAGER - Quantum API Tokens
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_code_engine_secret" "quantum_secrets" {
  project_id = ibm_code_engine_project.qcm5_project.project_id
  name       = "${local.name_prefix}-secrets"
  format     = "generic"

  data = {
    IBM_QUANTUM_TOKEN = var.ibm_quantum_token
  }
}

# ═══════════════════════════════════════════════════════════════════════
# EVENT STREAMS - Flash Sync Event Bus
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_resource_instance" "event_streams" {
  name              = "${local.name_prefix}-events"
  service           = "messagehub"
  plan              = local.service_plan
  location          = var.region
  resource_group_id = local.resource_group_id

  tags = var.tags
}

resource "ibm_resource_key" "event_streams_key" {
  name                 = "${local.name_prefix}-events-key"
  resource_instance_id = ibm_resource_instance.event_streams.id
  role                 = "Manager"
}

# ═══════════════════════════════════════════════════════════════════════
# CLOUDANT - QCM5 State Database
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_cloudant" "qcm5_db" {
  name              = "${local.name_prefix}-db"
  location          = var.region
  plan              = local.service_plan
  resource_group_id = local.resource_group_id

  legacy_credentials = false
  include_data_events = true

  tags = var.tags
}

resource "ibm_cloudant_database" "quantum_jobs" {
  instance_crn  = ibm_cloudant.qcm5_db.crn
  db            = "quantum_jobs"
  partitioned   = false
}

resource "ibm_cloudant_database" "flash_sync_state" {
  instance_crn  = ibm_cloudant.qcm5_db.crn
  db            = "flash_sync_state"
  partitioned   = false
}

resource "ibm_cloudant_database" "qec_syndromes" {
  instance_crn  = ibm_cloudant.qcm5_db.crn
  db            = "qec_syndromes"
  partitioned   = false
}
