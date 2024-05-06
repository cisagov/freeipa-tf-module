locals {
  # Default tags to apply to all AWS resources created
  tags = {
    Testing = true
  }
}

provider "aws" {
  default_tags {
    tags = local.tags
  }
  profile = "cool-sharedservices-provisionaccount"
  region  = "us-east-1"
}

provider "aws" {
  alias = "provision_ssm_parameter_read_role"
  default_tags {
    tags = local.tags
  }
  profile = "cool-images-provisionparameterstorereadroles"
  region  = "us-east-1"
}

#-------------------------------------------------------------------------------
# Create a subnet inside a VPC.
#-------------------------------------------------------------------------------
resource "aws_vpc" "the_vpc" {
  cidr_block           = "10.99.48.0/24"
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.99.48.0/24"
  vpc_id            = aws_vpc.the_vpc.id
}

#-------------------------------------------------------------------------------
# Set up external access and routing in the VPC.
#-------------------------------------------------------------------------------

# The internet gateway for the VPC
resource "aws_internet_gateway" "the_igw" {
  vpc_id = aws_vpc.the_vpc.id
}

# Default route table
resource "aws_default_route_table" "the_route_table" {
  default_route_table_id = aws_vpc.the_vpc.default_route_table_id
}

# Route all external traffic through the internet gateway
resource "aws_route" "route_external_traffic_through_internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.the_igw.id
  route_table_id         = aws_default_route_table.the_route_table.id
}

#-------------------------------------------------------------------------------
# Configure the server module.
#-------------------------------------------------------------------------------
module "ipa" {
  source = "../../"
  providers = {
    aws                                   = aws
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id                      = "207871073513" # The COOL Images account
  crowdstrike_falcon_sensor_customer_id_key = "/cdm/falcon/customer_id"
  crowdstrike_falcon_sensor_tags_key        = "/cdm/falcon/tags"
  domain                                    = "cal23.cyber.dhs.gov"
  hostname                                  = "ipa.cal23.cyber.dhs.gov"
  ip                                        = "10.99.48.4"
  nessus_hostname_key                       = "/cdm/nessus_hostname"
  nessus_key_key                            = "/cdm/nessus_key"
  nessus_port_key                           = "/cdm/nessus_port"
  netbios_name                              = "CAL23"
  realm                                     = "CAL23.CYBER.DHS.GOV"
  subnet_id                                 = aws_subnet.subnet.id
}
