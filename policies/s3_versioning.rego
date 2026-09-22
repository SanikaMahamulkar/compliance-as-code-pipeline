package terraform.s3_versioning

import rego.v1

# Control mapping:
# ISO 27001:2022 Annex A.8.13 - Information Backup

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket"
	resource_name := resource.name

	not versioning_configured(resource_name)

	msg := sprintf(
		"S3 bucket '%s' does not have versioning enabled (ISO 27001 A.8.13 - Information Backup)",
		[resource.change.after.bucket],
	)
}

versioning_configured(resource_name) if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket_versioning"
	resource.name == resource_name
	resource.change.after.versioning_configuration[0].status == "Enabled"
}
