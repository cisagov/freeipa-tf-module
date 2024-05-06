# The default tags configured for the default provider
data "aws_default_tags" "default" {}

# The IPA master EC2 instance
resource "aws_instance" "ipa" {
  ami                         = data.aws_ami.freeipa.id
  associate_public_ip_address = false
  availability_zone           = data.aws_subnet.the_subnet.availability_zone
  iam_instance_profile        = aws_iam_instance_profile.ipa.name
  instance_type               = var.aws_instance_type
  private_ip                  = var.ip
  subnet_id                   = var.subnet_id
  user_data_base64            = data.cloudinit_config.configure_freeipa.rendered
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags            = data.aws_default_tags.default.tags
  vpc_security_group_ids = var.security_group_ids

  # AWS Instance Meta-Data Service (IMDS) options
  metadata_options {
    # Enable IMDS (this is the default value)
    http_endpoint = "enabled"
    # Restrict put responses from IMDS to a single hop (this is the
    # default value).  This effectively disallows the retrieval of an
    # IMDSv2 token via this machine from anywhere else.
    http_put_response_hop_limit = 1
    # Require IMDS tokens AKA require the use of IMDSv2
    http_tokens = "required"
  }
  root_block_device {
    volume_size = var.root_disk_size
    volume_type = "gp3"
  }
}
