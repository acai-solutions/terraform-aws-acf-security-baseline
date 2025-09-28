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
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ SECURITY HUB - AGGREGATOR
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_securityhub_finding_aggregator" "sh_aggregator" {
  count = can(var.settings.aws_security_hub) ? 1 : 0

  linking_mode = "ALL_REGIONS"
}

resource "aws_securityhub_organization_configuration" "sh_aggregator" {
  count = can(var.settings.aws_security_hub) ? 1 : 0

  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.sh_aggregator[0]]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ GUARDDUTY - AGGREGATOR
# ---------------------------------------------------------------------------------------------------------------------
data "aws_guardduty_detector" "gd_aggregator" {
  count = can(var.settings.amazon_guardduty) ? 1 : 0
}

resource "aws_guardduty_organization_configuration" "gd_aggregator" {
  count = can(var.settings.amazon_guardduty) ? 1 : 0

  detector_id                      = data.aws_guardduty_detector.gd_aggregator[0].id
  auto_enable_organization_members = "ALL"
}

