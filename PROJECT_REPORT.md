# Compliance-as-Code CI/CD Pipeline - Project Report

Author: Sanika Mahamulkar, MSc Cybersecurity, University of Bristol
Repository: https://github.com/SanikaMahamulkar/compliance-as-code-pipeline
Date: September 2026

## Executive Summary

This project builds an automated compliance-as-code pipeline: Terraform infrastructure is evaluated against custom Open Policy Agent (OPA) policies, each mapped to specific ISO 27001:2022 and GDPR controls, with every push to the repository automatically generating a dated audit evidence report via CI/CD. It is the third in a series of three security engineering projects, focused specifically on the GRC/compliance-engineering discipline: translating written compliance controls into automated, enforceable, and evidenced checks, rather than manual periodic review.

Five policies were written and independently validated against a deliberately mixed Terraform configuration containing both compliant and non-compliant resources, confirming each policy correctly identifies violations without producing false positives on compliant resources. A control register documents the mapping between each policy and its underlying control, including an honest account of control areas not yet automated. A CI/CD pipeline runs the full check automatically on every push and uploads the resulting audit evidence as a build artifact.

## Objectives

1. Build a small, deliberately mixed set of Terraform infrastructure (some compliant, some not) to serve as a realistic policy-testing target.
2. Write OPA/Rego policies enforcing specific, cited compliance controls (ISO 27001, GDPR).
3. Validate each policy against real Terraform plan data, confirming it correctly distinguishes compliant from non-compliant resources.
4. Produce a control register - the actual GRC artifact mapping automated checks to their compliance source.
5. Build an audit evidence generator producing dated, structured reports.
6. Wire the full check into a CI/CD pipeline that runs automatically.

## Methodology

Terraform was used in plan-only mode throughout - no real AWS account or resources were ever provisioned. `terraform plan` output was converted to JSON (`terraform show -json`) and used as OPA's evaluation input, the standard approach for policy-as-code tooling operating on Terraform.

Each policy was validated, not merely written: every policy was run via `opa eval` against the real plan JSON and confirmed to (a) correctly flag the intended non-compliant resource with an accurate message, and (b) correctly not flag the corresponding compliant resource. A policy that had not passed both checks was not considered complete.

## Detection Results

All 5 policies passed validation:

| Policy | Control | Result |
|---|---|---|
| S3 encryption | ISO 27001 A.8.24, GDPR Art. 32(1)(a) | Correctly flagged non-compliant bucket only |
| S3 versioning | ISO 27001 A.8.13 | Correctly flagged non-compliant bucket only |
| S3 public access block | ISO 27001 A.5.15, GDPR Art. 32(1)(b) | Correctly flagged non-compliant bucket only |
| Security group SSH exposure | ISO 27001 A.8.20, A.8.22 | Correctly flagged non-compliant SG only |
| IAM wildcard permissions | ISO 27001 A.5.15, A.8.2 | Correctly flagged non-compliant policy only |

Full detail is in `control-register.md`.

## A Genuine Bug, Found and Fixed

The first policy written (S3 encryption) initially failed validation: it incorrectly flagged both the compliant and non-compliant bucket. Root cause: the policy matched on the bucket's `bucket` attribute directly, but at Terraform plan time this attribute is `(known after apply)` - unresolved - whenever it derives from a resource reference (`aws_s3_bucket.compliant_data.id`) rather than a literal string, which is the normal pattern in real Terraform code. The fix was to match on Terraform's own resource address (a stable identifier available at plan time regardless of whether downstream attributes are resolved) instead of the bucket name string. This is documented in `control-register.md` as part of the validation methodology, since a policy that appears to work but has not been tested against both a positive and negative case is a real, common way for compliance-as-code checks to silently fail to provide the assurance they claim to.

## CI/CD Pipeline

A GitHub Actions workflow runs on every push: it initializes and plans the sample Terraform, converts the plan to JSON, installs OPA, runs all five policies via the audit evidence generator script, and uploads the resulting report as a build artifact.

The pipeline initially failed twice during setup, for reasons worth recording:
1. The AWS provider attempted real credential resolution during `plan`, which GitHub Actions' runner environment rejected outright (no credential source available).
2. After adding placeholder AWS credentials as environment variables, the provider then attempted to validate those credentials against real AWS STS, which correctly rejected the fake token.

Both were resolved by setting `skip_credentials_validation`, `skip_requesting_account_id`, and `skip_region_validation` to `true` in the provider block - the documented, standard approach for a Terraform configuration that only ever runs `plan` and genuinely does not need real cloud access, which is this project's actual use case throughout.

## Control Register and Coverage Gaps

The full control register (`control-register.md`) maps all five policies to their ISO 27001:2022 Annex A controls and, where applicable, GDPR articles. It also explicitly documents three control areas not yet automated in this project - logging/monitoring requirements, data retention/deletion, and MFA enforcement - rather than presenting the five automated checks as complete coverage of a compliance programme. A control register that only shows what is covered, without acknowledging what is not, misrepresents the actual scope of assurance a pipeline like this provides; that distinction is treated as essential here.

## Conclusion

This project delivers a working, validated compliance-as-code pipeline: real Terraform, real policy evaluation, real CI/CD automation, and real audit evidence output - with every claim of "this control is enforced" backed by an actual test against both a passing and failing case, and every claim of "this control is not yet covered" stated plainly rather than omitted. Two real technical issues (the plan-time attribute resolution bug, and the CI credential handling) were found, root-caused, and fixed as part of building this, and both are documented as part of the project's own record rather than smoothed over.

## Skills Demonstrated

- Policy-as-code authoring in Rego (Open Policy Agent)
- Compliance control mapping: ISO 27001:2022 Annex A, GDPR articles
- Terraform plan-time data structures and their limitations
- CI/CD pipeline design (GitHub Actions) for compliance automation
- Audit evidence generation and reporting
- Validation methodology: treating "policy written" and "policy validated" as distinct, separately-evidenced claims
- Systematic debugging across a multi-tool pipeline (Terraform, OPA, GitHub Actions, Python)
- GRC documentation: control registers, coverage-gap transparency, audit-ready reporting
