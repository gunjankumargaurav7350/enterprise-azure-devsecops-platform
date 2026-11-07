# 🏛️ Enterprise Azure Platform Architecture

## Executive Overview
The **Enterprise Azure DevSecOps Platform** provides a production-grade, highly secure, and compliant cloud landing zone built according to the **Microsoft Cloud Adoption Framework (CAF)** and **Well-Architected Framework (WAF)** principles.

```mermaid
flowchart TD
    subgraph Internet ["🌐 External Traffic / Internet"]
        Users["Corporate Users / Clients"]
    end

    subgraph HubVNet ["🔵 Hub Virtual Network (10.0.0.0/16)"]
        Firewall["🔥 Azure Firewall Premium
(10.0.1.4)"]
        Bastion["🛡️ Azure Bastion Host
(10.0.2.0/24)"]
        AppGW["⚖️ Application Gateway WAF v2
(10.0.3.0/24)"]
        SharedSvc["🔌 Shared Services Subnet
(10.0.10.0/24)"]
    end

    subgraph SecurityVNet ["🔒 Security & Governance (KMS / IAM)"]
        KeyVault["🔑 Azure Key Vault
(Private Endpoint Only)
Purge Protection + RBAC"]
    end

    subgraph WorkloadVNet ["🟢 Workload Spoke VNet (10.100.0.0/16)"]
        AppSubnet["💻 App Tier Subnet
(10.100.1.0/24)"]
        DBSubnet["🗄️ Database Subnet
(10.100.2.0/24)"]
        PESubnet["🔗 Private Endpoints Subnet
(10.100.3.0/24)"]
    end

    subgraph ObservabilityMesh ["📊 Centralized Observability Mesh"]
        LAW["📋 Central Log Analytics
(365 Days Retention)"]
        ActionGroups["🚨 Action Groups
(SecOps & CoreOps)"]
        Grafana["📈 Azure Managed Grafana
Dashboards as Code"]
    end

    Users -->|HTTPS / WAF| AppGW
    AppGW --> Firewall
    Firewall -->|VNet Peering| AppSubnet
    AppSubnet -->|Private Link| DBSubnet
    AppSubnet -.->|Audit Logs & Metrics| LAW
    KeyVault -.->|Diagnostic Telemetry| LAW
    LAW --> ActionGroups
    LAW --> Grafana
```

---

## Core Pillars & Architectural Decisions

### 1. Hub-and-Spoke Network Topology
- **Hub Virtual Network (`10.0.0.0/16`)**: Acts as the central security and routing nexus. Houses Azure Firewall Premium, Azure Bastion for zero-public-IP VM administration, and Application Gateway with WAF v2 policies.
- **Spoke Virtual Network (`10.100.0.0/16`)**: Isolated workload environment connected via bi-directional VNet peering with non-overlapping address spaces.
- **Centralized Egress Routing**: Custom User Defined Routes (UDR) force all spoke outbound traffic (`0.0.0.0/0`) through the Hub Azure Firewall (`10.0.1.4`).

### 2. Zero-Trust Security & Identity
- **Private Link Exclusivity**: Public network access is strictly disabled on storage accounts and Azure Key Vault. All control and data planes communicate via Private Endpoints.
- **Role-Based Access Control (RBAC)**: Enforces Azure AD Least-Privilege access with no long-lived access keys.
- **Data Protection**: 90-day soft delete retention with hardware-enforced purge protection on all Key Vault instances.

### 3. Shift-Left Security Pipeline Gates
- **Static IaC Scanning**: Automated tfsec, Checkov, and TFLint gates scan every commit.
- **Secret Detection**: TruffleHog verifies no credentials or tokens are committed.
- **Container Scanning**: Trivy scans container images for CVEs before admission.
- **Terratest Automation**: Automated Go integration tests spin up ephemeral sandboxes to validate connectivity before production promotion.

### 4. Agentic AI Plan & Blast Radius Evaluation
- Automatically calculates blast radius score (0-100) on Terraform plans.
- Flags destructive resource deletions, security downgrades, or unintended route modifications.
- Generates structured Markdown pull request reviews with compliance sign-offs.

### 5. Supply Chain Integrity (SLSA Level 3)
- Generates Software Bill of Materials (SBOM) using Syft in SPDX format.
- Signs artifacts and manifests cryptographically with Sigstore Cosign.
- Enforces admission verification via Kyverno policies inside the cluster.

### 6. Observability as Code
- Unified telemetry routing to Central Log Analytics Workspace.
- Proactive multi-tier alerting for CPU, memory, database latency, and 5xx errors.
- Activity Log alerting for unauthorized privilege escalation attempts.
