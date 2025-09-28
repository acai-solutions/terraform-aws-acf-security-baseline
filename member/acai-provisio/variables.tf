# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "provisio_settings" {
  description = "ACAI PROVISIO settings"
  type = object({
    provisio_package_name = optional(string, "security-baseline")
    provisio_regions = object({
      primary_region    = string
      secondary_regions = list(string)
    })
    import_resources = optional(bool, false)
  })
}

variable "settings" {
  description = "Account hardening settings"
  type = object({
    aws_security_hub = optional(object({
      enable_default_standards = optional(bool, true)
      control_finding_generator = optional(string, "SECURITY_CONTROL")
      auto_enable_controls = optional(bool, true)
    }), null)
    amazon_guardduty = optional(object({
    }), null)
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
