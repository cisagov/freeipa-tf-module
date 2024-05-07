# ------------------------------------------------------------------------------
# Automatically look up the latest pre-built FreeIPA AMI from
# cisagov/freeipa-packer.
#
# NOTE: This Terraform data source must return at least one AMI result
# or the apply will fail.
# ------------------------------------------------------------------------------

# The AMI from cisagov/freeipa-packer
data "aws_ami" "freeipa" {
  filter {
    name = "name"
    values = [
      "freeipa-server-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  most_recent = true
  # This is the CyHy production (Raytheon) account
  owners = [var.ami_owner_account_id]
}
