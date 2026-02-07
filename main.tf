terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
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

locals {
  resource_group_id = local.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.default[0].id
}

# ═══════════════════════════════════════════════════════════════════════
# CODE ENGINE PROJECT - Serverless QCM5 Platform
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_code_engine_project" "qcm5_project" {
  name              = "${var.instance_name}-project"
  resource_group_id = local.resource_group_id
}

# QCM5 API Application - Placeholder (swap image when custom built)
resource "ibm_code_engine_app" "qcm5_api" {
  project_id      = ibm_code_engine_project.qcm5_project.project_id
  name            = "${var.instance_name}-api"
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
  name            = "${var.instance_name}-flash-sync"
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
  name            = "${var.instance_name}-qec-decoder"
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
# SECRETS MANAGER - Quantum API Tokens
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_code_engine_secret" "quantum_secrets" {
  project_id = ibm_code_engine_project.qcm5_project.project_id
  name       = "${var.instance_name}-secrets"
  format     = "generic"

  data = {
    IBM_QUANTUM_TOKEN = var.ibm_quantum_token
  }
}

# ═══════════════════════════════════════════════════════════════════════
# EVENT STREAMS - Flash Sync Event Bus
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_resource_instance" "event_streams" {
  name              = "${var.instance_name}-events"
  service           = "messagehub"
  plan              = "lite"
  location          = var.region
  resource_group_id = local.resource_group_id

  tags = var.tags
}

resource "ibm_resource_key" "event_streams_key" {
  name                 = "${var.instance_name}-events-key"
  resource_instance_id = ibm_resource_instance.event_streams.id
  role                 = "Manager"
}

# ═══════════════════════════════════════════════════════════════════════
# CLOUDANT - QCM5 State Database
# ═══════════════════════════════════════════════════════════════════════

resource "ibm_cloudant" "qcm5_db" {
  name              = "${var.instance_name}-db"
  location          = var.region
  plan              = "lite"
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
