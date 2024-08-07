variable "environment" {
  description = "The  environment. [test, dev, impl, prod]"
  type        = string

  validation {
    condition     = can(regex("test|dev|impl|prod", var.environment))
    error_message = "The environment value must be test, dev, impl, or prod."
  }
}

variable "location" {
  description = "The location of resources being created"
  type        = string
}

variable "application" {
  description = "The short name of the app or acronym"
  type        = string
}

variable "ado" {
  description = "The short name of the app or acronym"
  type        = string
}

variable "subscription_id" {
  description = "The subscription id"
  type = string  
}

variable "tenant_id" {
  description = "Azure tenant id"
  type = string
}