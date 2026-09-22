package terraform.s3_public_access

import rego.v1

# Control mapping:
# ISO 27001:2022 Annex A.5.15 - Access Control
# GDPR Article 32(1)(b) - Confidentiality of processing systems

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket"
	resource_name := resource.name

	not public_access_blocked(resource_name)

	msg := sprintf(
		"S3 bucket '%s' has no public access block configured (ISO 27001 A.5.15, GDPR Art. 32(1)(b))",
		[resource.change.after.bucket],
	)
}

public_access_blocked(resource_name) if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket_public_access_block"
	resource.name == resource_name
	resource.change.after.block_public_acls == true
	resource.change.after.block_public_policy == true
}
