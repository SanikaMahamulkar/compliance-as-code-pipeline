#!/usr/bin/env python3
"""
Audit evidence generator for the compliance-as-code pipeline.
Runs all OPA policies against the current Terraform plan and produces
a dated, structured Markdown report suitable for audit evidence.
"""

import json
import subprocess
import sys
from datetime import datetime, timezone

POLICIES = [
    {
        "file": "policies/s3_encryption.rego",
        "package": "terraform.s3_encryption",
        "control": "ISO 27001 A.8.24 / GDPR Art. 32(1)(a)",
        "name": "S3 Bucket Encryption",
    },
    {
        "file": "policies/s3_versioning.rego",
        "package": "terraform.s3_versioning",
        "control": "ISO 27001 A.8.13",
        "name": "S3 Bucket Versioning",
    },
    {
        "file": "policies/s3_public_access.rego",
        "package": "terraform.s3_public_access",
        "control": "ISO 27001 A.5.15 / GDPR Art. 32(1)(b)",
        "name": "S3 Public Access Block",
    },
    {
        "file": "policies/security_group_ssh.rego",
        "package": "terraform.security_group_ssh",
        "control": "ISO 27001 A.8.20 / A.8.22",
        "name": "Security Group SSH Exposure",
    },
    {
        "file": "policies/iam_wildcard.rego",
        "package": "terraform.iam_wildcard",
        "control": "ISO 27001 A.5.15 / A.8.2",
        "name": "IAM Wildcard Permissions",
    },
]

TFPLAN = "terraform/tfplan.json"


def run_policy(policy):
    query = f"data.{policy['package']}.deny"
    result = subprocess.run(
        ["opa", "eval", "--format", "json", "--data", policy["file"], "--input", TFPLAN, query],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return {"error": result.stderr.strip()}

    output = json.loads(result.stdout)
    violations = output["result"][0]["expressions"][0]["value"]
    return {"violations": violations}


def main():
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    total_checks = len(POLICIES)
    total_violations = 0
    sections = []

    for policy in POLICIES:
        result = run_policy(policy)
        if "error" in result:
            sections.append(f"### {policy['name']}\n\n**ERROR running policy:** {result['error']}\n")
            continue

        violations = result["violations"]
        total_violations += len(violations)
        status = "FAIL" if violations else "PASS"

        section = f"### {policy['name']}\n\n"
        section += f"- **Control:** {policy['control']}\n"
        section += f"- **Status:** {status}\n"
        section += f"- **Violations found:** {len(violations)}\n"
        if violations:
            section += "\n**Details:**\n"
            for v in violations:
                section += f"- {v}\n"
        sections.append(section)

    report = f"# Audit Evidence Report\n\n"
    report += f"**Generated:** {timestamp}\n"
    report += f"**Checks run:** {total_checks}\n"
    report += f"**Total violations found:** {total_violations}\n\n"
    report += "---\n\n"
    report += "\n".join(sections)

    output_path = f"audit-evidence/report-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.md"
    import os
    os.makedirs("audit-evidence", exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)

    print(report)
    print(f"\nReport saved to: {output_path}")


if __name__ == "__main__":
    main()
