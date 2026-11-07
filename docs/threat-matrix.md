# 🛡️ Threat Modeling & Defensive Controls Matrix

| Threat ID | Threat Vector | STRIDE Category | Defensive Control in Platform |
| :--- | :--- | :--- | :--- |
| **TM-01** | Unauthorized public internet access to database | Information Disclosure / Elevation of Privilege | Subnet private endpoints only; public network access disabled. |
| **TM-02** | Stolen credentials in Git commits | Spoofing / Repudiation | Shift-left TruffleHog pre-commit and CI/CD secret scanner. |
| **TM-03** | Insecure Terraform configuration (e.g. unencrypted storage) | Tampering / Information Disclosure | Mandatory tfsec and Checkov gates with soft-fail threshold 0. |
| **TM-04** | Tampered container images deployed to production | Tampering / Elevation of Privilege | Sigstore Cosign cryptographic signing + Kyverno admission controller. |
| **TM-05** | Unauthorized resource modification or deletion | Denial of Service | Key Vault purge protection + Terraform remote state lease locking. |
| **TM-06** | Lateral movement across virtual networks | Elevation of Privilege | Strict NSG baseline rules with DenyAllInboundInternet and Hub Firewall filtering. |
