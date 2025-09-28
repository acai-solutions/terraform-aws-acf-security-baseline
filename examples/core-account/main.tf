# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.47"
      configuration_aliases = []
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" { provider = aws.core_security }
data "aws_caller_identity" "current" { provider = aws.core_security }

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  regions_settings = {
    primary_region    = "eu-central-1"
    secondary_regions = ["us-east-2"]
  }
  aws_security_baseline_settings = {
    core_account = {
      aws_security_hub = {}
      amazon_guardduty = {}
    }
    account_baseline = {
      aws_security_hub = {}
      amazon_guardduty = {}
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ CENTRAL SECURITY SERVICES
# ---------------------------------------------------------------------------------------------------------------------
module "central_security" {
  source = "./scp_statements"
  settings = local.aws_security_baseline_settings.core_account
  providers = {
    aws = aws.core_security
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ RENDER MEMBER TERRAFORM
# ---------------------------------------------------------------------------------------------------------------------
module "member_files" {
  source = "../../member/acai-provisio"

  provisio_settings = {
    provisio_regions = local.regions_settings
  }
  settings = local.account_baseline.core_account
}


# Loop through the map and create a file for each entry
resource "local_file" "package_files" {
  for_each = module.member_files.provisio_package_files

  filename = "${path.module}/../member-provisio/rendered/${each.key}" # Each key becomes the filename
  content  = each.value                                               # Each value becomes the file content
}
