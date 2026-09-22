# Compliance-as-Code CI/CD Pipeline

An automated compliance checking pipeline: Terraform infrastructure is evaluated against custom OPA/Rego policies mapped to real ISO 27001 and GDPR controls, with every push automatically generating a dated audit evidence report.

This project complements [aws-cloud-security-baseline](https://github.com/SanikaMahamulkar/aws-cloud-security-baseline) and [soc-detection-lab](https://github.com/SanikaMahamulkar/soc-detection-lab): where those focus on building and monitoring infrastructure, this project focuses on the GRC/compliance-engineering side - proving infrastructure meets specific, cited control requirements, automatically, on every change.

## Tech stack

- **IaC:** Terraform (sample infrastructure with deliberate compliant/non-compliant resources)
- **Policy engine:** Open Policy Agent (OPA) with custom Rego policies
- **CI/CD:** GitHub Actions
- **Evidence generation:** Python script producing dated Markdown audit reports

## Repository structure

- `terraform/` - sample AWS infrastructure, deliberately mixing compliant and non-compliant resource configurations
- `policies/` - 5 OPA/Rego policies, each mapped to specific ISO 27001/GDPR controls
- `control-register.md` - the control-to-policy mapping document, including documented coverage gaps
- `generate-audit-evidence.py` - runs all policies and produces a dated audit evidence report
- `audit-evidence/` - generated reports
- `.github/workflows/` - CI pipeline running the full check on every push

## Progress log

- [x] Sample Terraform with deliberate compliant/non-compliant resources
- [x] 5 OPA/Rego policies written and validated (S3 encryption, versioning, public access; security group SSH exposure; IAM wildcard permissions)
- [x] Control register mapping all 5 policies to ISO 27001:2022 and GDPR articles, with documented coverage gaps
- [x] Audit evidence generator script - produces dated, structured Markdown reports
- [x] CI/CD pipeline (GitHub Actions) - automatically runs Terraform plan, OPA checks, and evidence generation on every push
- [ ] Full project report

## Known Issues / Notes

- The AWS provider is configured with `skip_credentials_validation`, `skip_requesting_account_id`, and `skip_region_validation` set to `true`, since this project only ever runs `terraform plan` (never `apply`) and needs no real AWS account - CI initially failed when the provider attempted to validate mock credentials against real AWS STS.
- One policy (S3 encryption) initially had a bug during development: it matched on the S3 bucket's `bucket` attribute, which is unresolved (`known after apply`) at plan time when derived from a resource reference. Fixed by matching on Terraform resource address instead - documented in `control-register.md`.

## Author

Sanika Mahamulkar - MSc Cybersecurity, University of Bristol
