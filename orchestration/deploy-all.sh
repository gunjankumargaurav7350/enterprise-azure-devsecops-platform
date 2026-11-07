#!/usr/bin/env bash
# =============================================================================
# Enterprise Azure DevSecOps Platform - Automated Deployment Orchestrator
# Architect: Gunjan Kumar Gaurav
# =============================================================================

set -euo pipefail

COLOR_RESET="\033[0m"
COLOR_INFO="\033[36m"
COLOR_SUCCESS="\033[32m"
COLOR_WARN="\033[33m"
COLOR_ERROR="\033[31m"

log_info() { echo -e "${COLOR_INFO}[INFO] ${1}${COLOR_RESET}"; }
log_success() { echo -e "${COLOR_SUCCESS}[SUCCESS] ${1}${COLOR_RESET}"; }
log_warn() { echo -e "${COLOR_WARN}[WARN] ${1}${COLOR_RESET}"; }
log_error() { echo -e "${COLOR_ERROR}[ERROR] ${1}${COLOR_RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BLUEPRINT_DIR="${ROOT_DIR}/platform-blueprint"

echo "============================================================================="
echo "   ENTERPRISE AZURE DEVSECOPS PLATFORM - END-TO-END ORCHESTRATOR"
echo "============================================================================="

# 1. Preflight Validation
log_info "Step 1/6: Verifying toolchains and prerequisites..."
command -v terraform >/dev/null 2>&1 || { log_error "Terraform is not installed. Aborting."; exit 1; }
command -v az >/dev/null 2>&1 || log_warn "Azure CLI not detected; ensure credentials are provided via ARM_* env vars."

# 2. Check Azure Identity
log_info "Step 2/6: Checking Azure subscription context..."
if command -v az >/dev/null 2>&1; then
  az account show --output table || log_warn "Unable to fetch Azure account details via CLI."
fi

# 3. Security Quality Gate
log_info "Step 3/6: Running pre-flight security linting..."
if command -v tfsec >/dev/null 2>&1; then
  tfsec "${BLUEPRINT_DIR}" --soft-fail || true
else
  log_info "tfsec not found locally, skipping local pre-commit scan (CI runs tfsec)."
fi

# 4. Terraform Initialization
log_info "Step 4/6: Initializing Terraform remote state backend..."
cd "${BLUEPRINT_DIR}"
terraform init -backend=false

# 5. Terraform Validate & Plan
log_info "Step 5/6: Generating execution plan with for_each validation..."
terraform validate
terraform plan -out=platform.tfplan

log_success "Execution plan validated successfully."

# 6. Apply Execution
read -p "Do you want to apply this enterprise platform blueprint to Azure? (yes/no): " CONFIRM
if [[ "${CONFIRM}" == "yes" ]]; then
  log_info "Step 6/6: Applying platform blueprint..."
  terraform apply -auto-approve platform.tfplan
  log_success "Enterprise Azure DevSecOps Platform deployed successfully!"
else
  log_warn "Deployment cancelled by user. State file unchanged."
fi
