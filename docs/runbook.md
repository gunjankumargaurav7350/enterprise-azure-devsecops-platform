# 📖 Enterprise Operations & Incident Response Runbook

## 1. Routine Maintenance
- **State File Verification**: Ensure Azure Blob lease state locking is active and healthy.
- **Provider Upgrades**: Regularly evaluate Terraform provider upgrades using Dependabot.
- **Certificate Rotation**: Monitor Key Vault certificate expiration alerts triggered 30 days prior to expiry.

## 2. Disaster Recovery Protocol
1. **Secondary Region Activation**: In the event of primary region outage (`eastus`), deploy blueprint to secondary region (`centralus`) via `Deploy-All.ps1 -Environment prod -SecondaryRegion`.
2. **DNS Failover**: Update Traffic Manager or Azure Front Door profiles to re-route incoming traffic to secondary Hub.
3. **Key Vault Backup Restore**: Restore Key Vault secrets and HSM-backed keys from geo-redundant backups.

## 3. Incident Escalation Paths
- **High Severity (P1/P0)**: Auto-escalated to `ag-platform-secops-urgent` Action Group.
- **Operational Degradation (P2/P3)**: Managed by `ag-platform-core-ops` Action Group.
