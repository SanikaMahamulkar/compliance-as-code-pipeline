package terraform.security_group_ssh

import rego.v1

# Control mapping:
# ISO 27001:2022 Annex A.8.20 - Networks Security
# ISO 27001:2022 Annex A.8.22 - Segregation of Networks

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_security_group"
	some rule in resource.change.after.ingress
	rule.from_port <= 22
	rule.to_port >= 22
	some cidr in rule.cidr_blocks
	cidr == "0.0.0.0/0"

	msg := sprintf(
		"Security group '%s' allows unrestricted SSH access from 0.0.0.0/0 (ISO 27001 A.8.20, A.8.22)",
		[resource.change.after.name],
	)
}
