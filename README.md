# freeipa-server-tf-module #

[![GitHub Build Status](https://github.com/cisagov/freeipa-server-tf-module/workflows/build/badge.svg)](https://github.com/cisagov/freeipa-server-tf-module/actions)

A Terraform module for deploying a FreeIPA server.

## Usage ##

```hcl
module "ipa0" {
  source = "github.com/cisagov/freeipa-server-tf-module"

  crowdstrike_falcon_sensor_customer_id_key = "/thulsa/doom/falcon/customer_id"
  crowdstrike_falcon_sensor_tags_key        = "/thulsa/doom/falcon/tags"
  domain                                    = "example.com"
  hostname                                  = "ipa0.example.com"
  ip                                        = "10.10.10.4"
  nessus_hostname_key                       = "/thulsa/doom/nessus/hostname"
  nessus_key_key                            = "/thulsa/doom/nessus/key"
  nessus_port_key                           = "/thulsa/doom/nessus/port"
  netbios_name                              = "EXAMPLE"
  realm                                     = "EXAMPLE.COM"
  security_group_ids                        = ["sg-51530134", "sg-51530245"]
  subnet_id                                 = aws_subnet.first_subnet.id
}

module "ipa1" {
  source = "github.com/cisagov/freeipa-server-tf-module"

  crowdstrike_falcon_sensor_customer_id_key = "/thulsa/doom/falcon/customer_id"
  crowdstrike_falcon_sensor_tags_key        = "/thulsa/doom/falcon/tags"
  domain                                    = "example.com"
  hostname                                  = "ipa1.example.com"
  ip                                        = "10.10.10.5"
  nessus_hostname_key                       = "/thulsa/doom/nessus/hostname"
  nessus_key_key                            = "/thulsa/doom/nessus/key"
  nessus_port_key                           = "/thulsa/doom/nessus/port"
  netbios_name                              = "EXAMPLE"
  security_group_ids                        = ["sg-51530134", "sg-51530245"]
  subnet_id                                 = aws_subnet.second_subnet.id
}
```

## Examples ##

- [Basic usage](https://github.com/cisagov/freeipa-server-tf-module/tree/develop/examples/basic_usage)

<!-- BEGIN_TF_DOCS -->
## Requirements ##

| Name | Version |
|------|---------|
| terraform | >= 1.1 |
| aws | >= 4.9 |
| cloudinit | ~> 2.0 |

## Providers ##

| Name | Version |
|------|---------|
| aws | >= 4.9 |
| cloudinit | ~> 2.0 |

## Modules ##

| Name | Source | Version |
|------|--------|---------|
| read\_ssm\_parameters | github.com/cisagov/ssm-read-role-tf-module | n/a |

## Resources ##

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ipa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ipa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.ipa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.freeipa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_arn.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_caller_identity.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.the_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.the_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [cloudinit_config.configure_freeipa](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_owner\_account\_id | The ID of the AWS account that owns the FreeIPA server AMI, or "self" if the AMI is owned by the same account as the provisioner. | `string` | `"self"` | no |
| aws\_instance\_type | The AWS instance type to deploy (e.g. t3.medium).  Two gigabytes of RAM is given as a minimum requirement for FreeIPA, but I have had intermittent problems when creating t3.small replicas. | `string` | `"t3.medium"` | no |
| crowdstrike\_falcon\_sensor\_customer\_id\_key | The SSM Parameter Store key whose corresponding value contains the customer ID for CrowdStrike Falcon (e.g. /cdm/falcon/customer\_id). | `string` | n/a | yes |
| crowdstrike\_falcon\_sensor\_install\_path | The install path of the CrowdStrike Falcon sensor (e.g. /opt/CrowdStrike). | `string` | `"/opt/CrowdStrike"` | no |
| crowdstrike\_falcon\_sensor\_tags\_key | The SSM Parameter Store key whose corresponding value contains a comma-delimited list of tags that are to be applied to CrowdStrike Falcon (e.g. /cdm/falcon/tags). | `string` | n/a | yes |
| domain | The domain for the IPA server (e.g. example.com). | `string` | n/a | yes |
| hostname | The hostname of the IPA server (e.g. ipa.example.com). | `string` | n/a | yes |
| ip | The IP address to assign the IPA server (e.g. 10.10.10.4).  Note that the IP address must be contained inside the CIDR block corresponding to subnet-id, and AWS reserves the first four and very last IP addresses.  We have to assign an IP in order to break the dependency of DNS record resources on the corresponding EC2 resources; otherwise, it is impossible to update the IPA servers one by one as is required when a new AMI is created. | `string` | n/a | yes |
| nessus\_agent\_install\_path | The install path of Nessus Agent (e.g. /opt/nessus\_agent). | `string` | `"/opt/nessus_agent"` | no |
| nessus\_groups | A list of strings, each of which is the name of a group in the CDM Tenable Nessus server that the Nessus Agent should join (e.g. ["group1", "group2"]). | `list(string)` | ```[ "COOL_Fed_32" ]``` | no |
| nessus\_hostname\_key | The SSM Parameter Store key whose corresponding value contains the hostname of the CDM Tenable Nessus server to which the Nessus Agent should link (e.g. /cdm/nessus/hostname). | `string` | n/a | yes |
| nessus\_key\_key | The SSM Parameter Store key whose corresponding value contains the secret key that the Nessus Agent should use when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/key). | `string` | n/a | yes |
| nessus\_port\_key | The SSM Parameter Store key whose corresponding value contains the port to which the Nessus Agent should connect when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/port). | `string` | n/a | yes |
| netbios\_name | The NetBIOS name to be used by the server (e.g. EXAMPLE).  Note that NetBIOS names are restricted to at most 15 characters.  These characters must consist only of uppercase letters, numbers, and dashes. | `string` | n/a | yes |
| realm | The realm for the IPA server (e.g. EXAMPLE.COM).  Only used if this IPA server IS NOT intended to be a replica. | `string` | `"EXAMPLE.COM"` | no |
| root\_disk\_size | The size of the IPA instance's root disk in GiB. | `number` | `8` | no |
| security\_group\_ids | A list of IDs corresponding to security groups to which the server should belong (e.g. ["sg-51530134", "sg-51530245"]).  Note that these security groups must exist in the same VPC as the server. | `list(string)` | `[]` | no |
| subnet\_id | The ID of the AWS subnet into which to deploy the IPA server (e.g. subnet-0123456789abcdef0). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| server | The IPA server EC2 instance. |
<!-- END_TF_DOCS -->

## Notes ##

Running `pre-commit` requires running `terraform init` in every
directory that contains Terraform code. In this repository, these are
the main directory and every directory under `examples/`.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
