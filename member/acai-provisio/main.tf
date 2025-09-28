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
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMPILE PROVISIO PACKAGES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = templatefile("${path.module}/templates/tags.tf.tftpl", {
    map_of_tags = merge(
      var.resource_tags,
      {
        "module_provider" = "ACAI GmbH",
        "module_name"     = "terraform-aws-acf-security-baseline",
        "module_source"   = "github.com/acai-consulting/security-baseline",
        "module_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
      }
    )
  })

  provisio_package_files = merge(
    {
      "requirements.tf" = templatefile("${path.module}/templates/requirements.tf.tftpl", {
        secondary_regions    = var.provisio_settings.provisio_regions.secondary_regions
        terraform_version    = ">= 1.3.10",
        provider_aws_version = ">= 4.00",
      })
      "main.tf" = templatefile("${path.module}/templates/main.tf.tftpl", {
        primary_region                             = var.provisio_settings.provisio_regions.primary_region
        secondary_regions                          = var.provisio_settings.provisio_regions.secondary_regions
        aws_security_hub_enabled                   = var.settings.aws_security_hub != null
        aws_security_hub_enable_default_standards  = try(var.settings.aws_security_hub.enable_default_standards, true)
        aws_security_hub_control_finding_generator = try(var.settings.aws_security_hub.control_finding_generator, "SECURITY_CONTROL")
        aws_security_hub_auto_enable_controls      = try(var.settings.aws_security_hub.auto_enable_controls, true)
        amazon_guardduty_enabled                   = var.settings.amazon_guardduty != null
        resource_tags                              = local.resource_tags
      })
    },
    var.provisio_settings.import_resources ? ({
      "import.list.part" = templatefile("${path.module}/templates/import.list.part.tftpl", {
        provisio_package_name    = replace(var.provisio_settings.provisio_package_name, "-", "_")
        primary_region           = var.provisio_settings.provisio_regions.primary_region
        secondary_regions        = var.provisio_settings.provisio_regions.secondary_regions
        aws_security_hub_enabled = var.settings.aws_security_hub != null
        amazon_guardduty_enabled = true //var.settings.amazon_guardduty != null 
      }),
    }) : {}
  )
}
