# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "crowdstrike_falcon_sensor_customer_id_key" {
  description = "The SSM Parameter Store key whose corresponding value contains the customer ID for CrowdStrike Falcon (e.g. /cdm/falcon/customer_id)."
  nullable    = false
  type        = string
}

variable "crowdstrike_falcon_sensor_tags_key" {
  description = "The SSM Parameter Store key whose corresponding value contains a comma-delimited list of tags that are to be applied to CrowdStrike Falcon (e.g. /cdm/falcon/tags)."
  nullable    = false
  type        = string
}

variable "domain" {
  description = "The domain for the IPA server (e.g. example.com)."
  nullable    = false
  type        = string
}

variable "hostname" {
  description = "The hostname of the IPA server (e.g. ipa.example.com)."
  nullable    = false
  type        = string
}

variable "ip" {
  description = "The IP address to assign the IPA server (e.g. 10.10.10.4).  Note that the IP address must be contained inside the CIDR block corresponding to subnet-id, and AWS reserves the first four and very last IP addresses.  We have to assign an IP in order to break the dependency of DNS record resources on the corresponding EC2 resources; otherwise, it is impossible to update the IPA servers one by one as is required when a new AMI is created."
  nullable    = false
  type        = string
}

variable "nessus_hostname_key" {
  description = "The SSM Parameter Store key whose corresponding value contains the hostname of the CDM Tenable Nessus server to which the Nessus Agent should link (e.g. /cdm/nessus/hostname)."
  nullable    = false
  type        = string
}

variable "nessus_key_key" {
  description = "The SSM Parameter Store key whose corresponding value contains the secret key that the Nessus Agent should use when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/key)."
  nullable    = false
  type        = string
}

variable "nessus_port_key" {
  description = "The SSM Parameter Store key whose corresponding value contains the port to which the Nessus Agent should connect when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/port)."
  nullable    = false
  type        = string
}

variable "netbios_name" {
  description = "The NetBIOS name to be used by the server (e.g. EXAMPLE).  Note that NetBIOS names are restricted to at most 15 characters.  These characters must consist only of uppercase letters, numbers, and dashes."
  nullable    = false
  type        = string
  validation {
    condition     = length(var.netbios_name) <= 15 && length(regexall("[^A-Z0-9-]", var.netbios_name)) == 0
    error_message = "NetBIOS names are restricted to at most 15 characters.  These characters must consist only of uppercase letters, numbers, and dashes."
  }
}

variable "subnet_id" {
  description = "The ID of the AWS subnet into which to deploy the IPA server (e.g. subnet-0123456789abcdef0)."
  nullable    = false
  type        = string
}

# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults, or they are only used in
# certain cases.
# ------------------------------------------------------------------------------

variable "ami_owner_account_id" {
  default     = "self"
  description = "The ID of the AWS account that owns the FreeIPA server AMI, or \"self\" if the AMI is owned by the same account as the provisioner."
  nullable    = false
  type        = string
}

variable "aws_instance_type" {
  default     = "t3.large"
  description = "The AWS instance type to deploy (e.g. t3.medium).  Two gigabytes of RAM is given as a minimum requirement for FreeIPA, but I have had intermittent problems when creating even t3.medium replicas using a Fedora 41 AMI."
  nullable    = false
  type        = string
}

variable "crowdstrike_falcon_sensor_install_path" {
  default     = "/opt/CrowdStrike"
  description = "The install path of the CrowdStrike Falcon sensor (e.g. /opt/CrowdStrike)."
  nullable    = false
  type        = string
}

variable "nessus_agent_install_path" {
  default     = "/opt/nessus_agent"
  description = "The install path of Nessus Agent (e.g. /opt/nessus_agent)."
  nullable    = false
  type        = string
}

variable "nessus_groups" {
  default     = ["COOL_Fed_32"]
  description = "A list of strings, each of which is the name of a group in the CDM Tenable Nessus server that the Nessus Agent should join (e.g. [\"group1\", \"group2\"])."
  nullable    = false
  type        = list(string)
}

variable "realm" {
  default     = "EXAMPLE.COM"
  description = "The realm for the IPA server (e.g. EXAMPLE.COM).  Only used if this IPA server IS NOT intended to be a replica."
  nullable    = false
  type        = string
}

variable "root_disk_size" {
  default     = 8
  description = "The size of the IPA instance's root disk in GiB."
  nullable    = false
  type        = number
}

variable "security_group_ids" {
  default     = []
  description = "A list of IDs corresponding to security groups to which the server should belong (e.g. [\"sg-51530134\", \"sg-51530245\"]).  Note that these security groups must exist in the same VPC as the server."
  nullable    = false
  type        = list(string)
}
