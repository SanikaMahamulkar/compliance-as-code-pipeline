package terraform.s3_encryption

import rego.v1

# Control mapping:
# ISO 27001:2022 Annex A.8.24 - Use of Cryptography
# GDPR Article 32(1)(a) - Encryption of personal data

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket"
	resource_name := resource.name

	not encryption_configured(resource_name)

	msg := sprintf(
		"S3 bucket '%s' has no server-side encryption configuration (ISO 27001 A.8.24, GDPR Art. 32(1)(a))",
		[resource.change.after.bucket],
	)
}

encryption_configured(resource_name) if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket_server_side_encryption_configuration"
	resource.name == resource_name
}
