# 🛡️ Security & Compliance Governance Matrix

| Compliance Framework | Requirement | Platform Implementation | Verification Gate |
| :--- | :--- | :--- | :--- |
| **CIS Azure Benchmark v2.0** | 1.1 Ensure MFA is enabled for all privileged users | Azure AD Conditional Access + PIM | Zero-Trust Identity Blueprint |
| **CIS Azure Benchmark v2.0** | 3.1 Ensure Storage Accounts require secure transfer | `enable_https_traffic_only = true`, TLS 1.2+ | Checkov & tfsec Gate |
| **CIS Azure Benchmark v2.0** | 4.1 Ensure Key Vault has Purge Protection enabled | `purge_protection_enabled = true`, 90d soft-delete | Terraform Module Baseline |
| **CIS Azure Benchmark v2.0** | 5.1 Ensure Network Security Groups restrict SSH/RDP | DenyAllInboundInternet baseline NSG rule | Automated IaC Scan |
| **NIST SP 800-53 Rev. 5** | AC-3 Access Enforcement | Azure RBAC with custom role definitions | Terraform RBAC Module |
| **NIST SP 800-53 Rev. 5** | AU-6 Audit Review, Analysis, and Reporting | Central Log Analytics (365d retention) | Observability as Code |
| **NIST SP 800-53 Rev. 5** | SC-7 Boundary Protection | Azure Firewall Hub-and-Spoke + UDRs | VNet Peering Mesh |
| **SLSA Level 3** | Supply Chain Integrity & Provenance | Syft SBOM + Cosign Cryptographic Signing | Supply Chain Security Pipeline |
| **SOC 2 Type II** | CC6.1 Logical Access Controls | Keyless OIDC Azure DevOps federation | Azure DevOps Multi-stage YAML |
| **SOC 2 Type II** | CC7.2 Continuous Vulnerability Scanning | Trivy + Grype container scanning in CI/CD | DevSecOps Pipeline Gate |
