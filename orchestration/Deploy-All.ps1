# =============================================================================
# Enterprise Azure DevSecOps Platform - Automated Deployment Orchestrator (PowerShell)
# Architect: Gunjan Kumar Gaurav
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "stage", "prod")]
    [string]$Environment = "prod",

    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BlueprintDir = Join-Path (Split-Path -Parent $ScriptDir) "platform-blueprint"

Write-Host "=============================================================================" -ForegroundColor Yellow
Write-Host "   ENTERPRISE AZURE DEVSECOPS PLATFORM - POWERSHELL ORCHESTRATOR" -ForegroundColor Yellow
Write-Host "=============================================================================" -ForegroundColor Yellow

# 1. Toolchain Check
Write-Step "Checking prerequisites (Terraform & Azure CLI)..."
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "Terraform CLI is not found in PATH. Please install Terraform."
}

# 2. Azure Context
Write-Step "Inspecting Azure context..."
if (Get-Command az -ErrorAction SilentlyContinue) {
    az account show --output table
}

# 3. Terraform Init
Write-Step "Initializing Terraform blueprint..."
Push-Location $BlueprintDir
try {
    terraform init -backend=false
    terraform validate
    Write-Success "Terraform configuration is valid."

    Write-Step "Generating Terraform Plan..."
    terraform plan -out=platform.tfplan

    if ($AutoApprove -or (Read-Host "Apply this plan to Azure? (y/n)") -eq 'y') {
        Write-Step "Applying enterprise infrastructure..."
        terraform apply -auto-approve platform.tfplan
        Write-Success "Enterprise Azure DevSecOps Platform deployment completed!"
    } else {
        Write-Host "Deployment aborted by user." -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}
