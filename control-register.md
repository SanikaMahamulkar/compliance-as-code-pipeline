# Control Register

This register maps automated policy-as-code checks (policies/) to their underlying compliance controls. Each row represents one enforced check, its control source, what it verifies, and its current validation status.

## Controls Covered

| Control ID | Framework | Control Description | Automated Check | Policy File | Status |
|---|---|---|---|---|---|
| A.8.24 | ISO 27001:2022 | Use of Cryptography | S3 buckets must have server-side encryption configured | policies/s3_encryption.rego | Validated |
| Art. 32(1)(a) | GDPR | Encryption of personal data | S3 buckets must have server-side encryption configured | policies/s3_encryption.rego | Validated |
| A.8.13 | ISO 27001:2022 | Information Backup | S3 buckets must have versioning enabled | policies/s3_versioning.rego | Validated |
| A.5.15 | ISO 27001:2022 | Access Control | S3 buckets must have public access blocked | policies/s3_public_access.rego | Validated |
| Art. 32(1)(b) | GDPR | Confidentiality of processing systems | S3 buckets must have public access blocked | policies/s3_public_access.rego | Validated |
| A.8.20 | ISO 27001:2022 | Networks Security | Security groups must not allow unrestricted (0.0.0.0/0) SSH ingress | policies/security_group_ssh.rego | Validated |
| A.8.22 | ISO 27001:2022 | Segregation of Networks | Security groups must not allow unrestricted (0.0.0.0/0) SSH ingress | policies/security_group_ssh.rego | Validated |
| A.5.15 | ISO 27001:2022 | Access Control | IAM policies must not grant unrestricted (Action:*, Resource:*) access | policies/iam_wildcard.rego | Validated |
| A.8.2 | ISO 27001:2022 | Privileged Access Rights | IAM policies must not grant unrestricted (Action:*, Resource:*) access | policies/iam_wildcard.rego | Validated |

## Validation Methodology

"Validated" means the policy was run via `opa eval` against a real Terraform plan containing both a deliberately compliant and a deliberately non-compliant resource, and confirmed to:
1. Correctly flag the non-compliant resource with an accurate, control-referenced message.
2. Correctly NOT flag the compliant resource (i.e. no false positives).

This distinguishes a control that is genuinely enforced by working code from one that is merely documented as a policy intention. During development, one policy (S3 encryption) initially failed this validation - it incorrectly flagged both the compliant and non-compliant bucket due to a Terraform plan-time data availability issue (the bucket name attribute is unresolved at plan time when derived from a resource reference rather than a literal). This was identified, fixed by matching on Terraform resource address instead of the bucket name string, and re-validated before being marked "Validated" in this register.

## Coverage Gaps (Not Yet Automated)

The following control areas are relevant to a real compliance programme but are not yet covered by an automated check in this project:

- Logging and monitoring requirements (ISO 27001 A.8.15/A.8.16) - would require checking for CloudTrail/logging resources, not present in this project's sample Terraform.
- Data retention and deletion (GDPR Art. 5(1)(e)) - requires lifecycle policy configuration checks, not yet written.
- Multi-factor authentication enforcement (ISO 27001 A.8.5) - not applicable to the resource types in this project's sample Terraform (IAM user MFA policy would need separate tooling).

These are listed explicitly rather than omitted, since a control register that only shows what is covered - without acknowledging what is not - would misrepresent the actual scope of assurance this pipeline provides.
