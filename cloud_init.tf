# This is used to extract the region where the IPA instance is being
# created
data "aws_arn" "subnet" {
  arn = data.aws_subnet.the_subnet.arn
}

data "cloudinit_config" "configure_freeipa" {
  base64_encode = true
  gzip          = true

  #-----------------------------------------------------------------------------
  # Cloud Config parts
  #-----------------------------------------------------------------------------

  # Note: All the cloud-config parts will write to the same file on
  # the instance at boot. To prevent one part from clobbering another,
  # you must specify a merge_type.  See:
  # https://cloudinit.readthedocs.io/en/latest/topics/merging.html#built-in-mergers
  #
  # The filename parameters are only used to identify the mime-part
  # headers in the user-data.

  # Set the local hostname.
  #
  # We need to go ahead and set the local hostname to the correct
  # value that will eventually be obtained from DHCP, since we make
  # liberal use of the "{local_hostname}" placeholder in our AWS
  # CloudWatch Agent configuration.
  part {
    content = templatefile(
      "${path.module}/cloud-init/set-hostname.tpl.yml", {
        # Note that the hostname must be identical to what is set in
        # the corresponding DNS A record.
        fqdn     = var.hostname
        hostname = split(".", var.hostname)[0]
    })
    content_type = "text/cloud-config"
    filename     = "set-hostname.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloud-init/freeipa-vars.tpl.yml", {
        domain       = var.domain
        hostname     = var.hostname
        netbios_name = var.netbios_name
        realm        = var.realm
    })
    filename   = "freeipa-vars.yml"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  #-------------------------------------------------------------------------------
  # Shell script parts
  #-------------------------------------------------------------------------------

  # Note: The filename parameters in each part below are used to name
  # the mime-parts of the user-data as well as the filename in the
  # scripts directory.

  part {
    # Note that text/x-python is not supported here:
    # https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/link-nessus-agent.py", {
        nessus_agent_install_path = var.nessus_agent_install_path
        nessus_groups             = join(",", var.nessus_groups)
        nessus_hostname_key       = var.nessus_hostname_key
        nessus_key_key            = var.nessus_key_key
        nessus_port_key           = var.nessus_port_key
        ssm_read_role_arn         = module.read_ssm_parameters.role.arn
        # This is the region where the IPA instance is being created
        ssm_region = data.aws_arn.subnet.region
    })
    filename = "link-nessus-agent.py"
  }

  part {
    # Note that text/x-python is not supported here:
    # https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/configure-falcon-sensor.py", {
        falcon_customer_id_key     = var.crowdstrike_falcon_sensor_customer_id_key
        falcon_sensor_install_path = var.crowdstrike_falcon_sensor_install_path
        falcon_tags_key            = var.crowdstrike_falcon_sensor_tags_key
        ssm_read_role_arn          = module.read_ssm_parameters.role.arn
        # This is the region where the FreeIPA instance is being
        # created
        ssm_region = data.aws_arn.subnet.region
    })
    filename = "configure-falcon-sensor.py"
  }
}
