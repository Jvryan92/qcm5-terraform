variable "instance_name" {
  description = "Name for the QCM5 service instance"
  type        = string
  default     = "qcm5-quantum-platform"
}

variable "plan" {
  description = "QCM5 pricing plan: free, professional, or enterprise"
  type        = string
  default     = "professional"
  validation {
    condition     = contains(["free", "professional", "enterprise"], var.plan)
    error_message = "Plan must be one of: free, professional, enterprise."
  }
}

variable "region" {
  description = "IBM Cloud region for the service instance"
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  description = "IBM Cloud Resource Group ID (leave empty to use Default resource group)"
  type        = string
  default     = ""
}

variable "enable_qec" {
  description = "Enable quantum error correction (surface code implementation)"
  type        = bool
  default     = true
}

variable "routing_mode" {
  description = "Backend routing mode: auto (fidelity-first) or manual"
  type        = string
  default     = "auto"
  validation {
    condition     = contains(["auto", "manual"], var.routing_mode)
    error_message = "Routing mode must be 'auto' or 'manual'."
  }
}

variable "tags" {
  description = "Tags to associate with the QCM5 instance"
  type        = list(string)
  default     = ["quantum", "qec", "qcm5", "model-council"]
}

variable "ibm_quantum_token" {
  description = "IBM Quantum API token for backend access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "council_worker_url" {
  description = "Cloudflare Worker URL for live Model Council gossip consensus engine"
  type        = string
  default     = "https://epochcore-unified-worker.epochcoreras.workers.dev"
}
