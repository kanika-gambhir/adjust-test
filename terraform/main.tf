
# Variables

variable "project" {
  
}
variable "region"{}

variable "imagetag" {
  
}

#Provider vars

variable "provider_client_id" {
  description = "Service Principle ID used by terraform Provider:"
}
variable "provider_client_secret" {
  description = "Service Principle Secret used by terraform Provider:"
}
variable "az_subscription_id" {
  description = "Azure Subscription ID:"
}

variable "az_tenant_id" {
  description = "Azure Tenant ID:"
}

# Modules
module "common" {
  source       = "./Common"
  region       = "${var.region}"
  project      = "${var.project}"
  imagetag  = "${var.imagetag}"
 }

 output "applicationendpoint" {
   value = "${module.common.applicationendpoint}"
 }
