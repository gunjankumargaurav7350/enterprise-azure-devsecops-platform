# 🌐 Enterprise Azure DevSecOps Platform

[![CI/CD Platform Orchestrator](https://github.com/gunjankumargaurav7350/enterprise-azure-devsecops-platform/actions/workflows/ci-cd-platform-orchestrator.yml/badge.svg)](https://github.com/gunjankumargaurav7350/enterprise-azure-devsecops-platform/actions/workflows/ci-cd-platform-orchestrator.yml)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-7B42BC?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud%20Adoption%20Framework-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Security](https://img.shields.io/badge/Security-Shift--Left%20%7C%20Zero--Trust-success)](#)
[![Compliance](https://img.shields.io/badge/Compliance-CIS%20Azure%20v2.0%20%7C%20NIST%20800--53-orange)](#)
[![SLSA Level 3](https://img.shields.io/badge/Supply%20Chain-SLSA%20Level%203%20%7C%20Cosign-blue)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Architect & Lead Engineer**: [Gunjan Kumar Gaurav](https://github.com/gunjankumargaurav7350)  
> **Target Cloud**: Microsoft Azure (Enterprise Hub-Spoke Landing Zone)  
> **IaC Pattern**: 100% Modular Terraform with strict `for_each` collections  
> **Security Baseline**: Zero-Trust, Shift-Left DevSecOps (tfsec, Checkov, Trivy, TruffleHog, Cosign, Kyverno)

---

## 🧭 Executive Architecture Blueprint

The **Enterprise Azure DevSecOps Platform** is an enterprise-scale, production-ready reference platform uniting six foundational pillars of modern cloud engineering:

```mermaid
graph TD
    classDef hub fill:#0078D4,stroke:#004578,stroke-width:2px,color:#fff;
    classDef security fill:#D83B01,stroke:#A80000,stroke-width:2px,color:#fff;
    classDef ops fill:#107C41,stroke:#0B5A2D,stroke-width:2px,color:#fff;
    classDef ai fill:#7B42BC,stroke:#4A154B,stroke-width:2px,color:#fff;

    Platform["🌐 Enterprise Azure DevSecOps Platform"]:::hub

    subgraph Infrastructure ["1. Infrastructure as Code & Landing Zones"]
        LZ["🏰 Azure Landing Zone (Hub-Spoke)"]:::hub
        Modules["🧱 Reusable Terraform Modules (for_each)"]:::hub
    end

    subgraph SecurityEngineering ["2. DevSecOps & Supply Chain Security"]
        Pipeline["🛡️ Shift-Left DevSecOps Pipeline"]:::security
        SupplyChain["📦 Supply Chain Security (SBOM & Cosign)"]:::security
    end

    subgraph AIAndObservability ["3. Agentic AI & Enterprise Observability"]
        AI["🤖 Agentic AI Plan Reviewer & Troubleshooter"]:::ai
        Obs["📊 Observability as Code (Alerts & Grafana)"]:::ops
    end

    Platform --> Infrastructure
    Platform --> SecurityEngineering
    Platform --> AIAndObservability
```

---

## 🧩 Architectural Repositories & Subsystem Matrix

This master umbrella repository unifies and orchestrates the following six specialized production-grade repositories:

| Subsystem / Pillar | Repository | Key Capabilities & Architecture | Primary Tech Stack |
| :--- | :--- | :--- | :--- |
| **1. Enterprise Landing Zone** | [`Azure-Landing-Zone-Terraform`](https://github.com/gunjankumargaurav7350/Azure-Landing-Zone-Terraform) | Hub-and-Spoke VNet peering mesh, Azure Firewall Premium, Azure Bastion, App Gateway WAF v2, Azure Policy enforcement. | Terraform, Azure CAF, UDR |
| **2. Modular IaC Library** | [`terraform-azure-modules`](https://github.com/gunjankumargaurav7350/terraform-azure-modules) | Zero-hardcoding reusable modules (VNet, NSG, Key Vault, RBAC) using strict `for_each`, Blob Lease state locking. | Terraform, HCL, Azure Blob Storage |
| **3. Shift-Left DevSecOps** | [`azure-devsecops-pipeline`](https://github.com/gunjankumargaurav7350/azure-devsecops-pipeline) | Azure DevOps multi-stage YAML + GitHub Actions with tfsec, Checkov, TFLint, Trivy, TruffleHog, and Terratest. (**30% security findings reduction**). | Azure Pipelines, GitHub Actions, Go |
| **4. Agentic AI Cloud SRE** | [`agentic-ai-terraform-reviewer`](https://github.com/gunjankumargaurav7350/agentic-ai-terraform-reviewer) | Autonomous AI agent for plan blast-radius scoring, CI/CD pipeline failure diagnostics, and human-in-the-loop approval gates. | Python, Click, Rich, LLM Agent |
| **5. Supply Chain Integrity** | [`supply-chain-security-sbom-cosign`](https://github.com/gunjankumargaurav7350/supply-chain-security-sbom-cosign) | Automated Syft SBOM generation, Grype/Trivy vulnerability gates, cryptographic Cosign signing, and Kyverno admission policies. | Syft, Cosign, Kyverno, Docker |
| **6. Observability as Code** | [`azure-observability-as-code`](https://github.com/gunjankumargaurav7350/azure-observability-as-code) | Centralized Log Analytics, dynamic Action Groups with `for_each`, Metric Alerts, Activity Log alerts, Azure Managed Grafana dashboards. | Terraform, Azure Monitor, Grafana |

---

## 🚀 Hub-and-Spoke Topology & Network Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as User / Application Client
    participant AppGW as Azure App Gateway (WAF)
    participant FW as Azure Firewall Premium (Hub)
    participant Spoke as Workload Spoke (Subnets)
    participant KV as Azure Key Vault (Private Link)
    participant LAW as Log Analytics Workspace

    User->>AppGW: Inbound HTTPS Request (Port 443)
    AppGW->>FW: Inspect & Forward Traffic (Port 8080)
    FW->>Spoke: Route to Workload Tier via VNet Peering
    Spoke->>KV: Authenticate & Retrieve Secret (via Private Endpoint)
    KV-->>Spoke: Return Encryption Key / Secret
    Spoke->>LAW: Emit Container Diagnostics & Audit Logs
    FW->>LAW: Emit Network Flow Logs
```

---

## 🛠️ Repository Directory Layout

```text
enterprise-azure-devsecops-platform/
├── .github/
│   └── workflows/
│       └── ci-cd-platform-orchestrator.yml  # End-to-end multi-gate CI/CD orchestrator
├── docs/
│   ├── architecture.md                     # Deep-dive CAF architecture & network flow
│   ├── security-governance.md              # CIS Azure v2.0 & NIST 800-53 compliance matrix
│   ├── threat-matrix.md                    # Attack vector & defensive mitigation analysis
│   └── runbook.md                          # Production operations and disaster recovery
├── orchestration/
│   ├── deploy-all.sh                       # Enterprise Bash deployment orchestrator
│   ├── Deploy-All.ps1                      # Cross-platform PowerShell orchestrator
│   └── verify-platform.sh                  # Live health check & compliance verification
├── platform-blueprint/                     # Master Terraform landing zone configuration
│   ├── backend.tf                          # Azure Blob lease state locking
│   ├── versions.tf                         # Provider version locks (azurerm >= 3.116)
│   ├── variables.tf                        # Enterprise configuration schemas
│   ├── main.tf                             # Hub-Spoke, RBAC, Policy, KV, LAW with for_each
│   ├── outputs.tf                          # Endpoints, VNet IDs, and telemetry outputs
│   └── terraform.tfvars.example            # Production variables baseline
└── README.md                               # Project documentation & visual blueprints
```

---

## ⚡ Quick Start: Deploying the Platform

### Prerequisites
1. **Azure CLI** (`az login`) with Owner or Contributor + User Access Administrator on the target subscription.
2. **Terraform CLI** (`>= 1.5.0`).
3. Active Azure Storage Account configured for remote state backend.

### 1. Clone the Repository
```bash
git clone https://github.com/gunjankumargaurav7350/enterprise-azure-devsecops-platform.git
cd enterprise-azure-devsecops-platform
```

### 2. Configure Variables
```bash
cp platform-blueprint/terraform.tfvars.example platform-blueprint/terraform.tfvars
```

### 3. Automated Orchestration via Bash or PowerShell
Using Bash:
```bash
chmod +x orchestration/deploy-all.sh orchestration/verify-platform.sh
./orchestration/deploy-all.sh
```

Using PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\orchestration\Deploy-All.ps1 -Environment "prod"
```

### 4. Verify Platform Health
```bash
./orchestration/verify-platform.sh
```

---

## 🔒 Security Quality Gates & Compliance

Every pull request triggers the automated **Platform CI/CD Orchestrator** executing 5 sequential shift-left quality gates:
1. **Format & Syntax Validation**: `terraform fmt -check` & `terraform validate`.
2. **IaC Security Scanning**: `tfsec` and `Checkov` ensuring 0 critical/high findings.
3. **Secret Leak Prevention**: `TruffleHog` analyzing git commit history.
4. **Agentic AI Evaluation**: AI agent reviews plan diff, scores blast radius, and flags risk.
5. **Supply Chain Gate**: `Syft` generates SPDX SBOM; `Cosign` signs artifacts; `Kyverno` validates admission policies.

---

## 👤 Author & Maintainer

**Gunjan Kumar Gaurav**  
Senior Azure DevOps & Cloud Security Platform Engineer  
- 💼 [GitHub Profile](https://github.com/gunjankumargaurav7350)  
- 📜 [LinkedIn Profile](https://www.linkedin.com/in/gunjankumargaurav)

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
