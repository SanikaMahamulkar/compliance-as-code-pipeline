package terraform.iam_wildcard

import rego.v1

# Control mapping:
# ISO 27001:2022 Annex A.5.15 - Access Control
# ISO 27001:2022 Annex A.8.2 - Privileged Access Rights

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_iam_policy"
	policy_doc := json.unmarshal(resource.change.after.policy)
	some statement in policy_doc.Statement
	statement.Effect == "Allow"
	statement.Action == "*"
	statement.Resource == "*"

	msg := sprintf(
		"IAM policy '%s' grants unrestricted access (Action: *, Resource: *) - violates least privilege (ISO 27001 A.5.15, A.8.2)",
		[resource.change.after.name],
	)
}
