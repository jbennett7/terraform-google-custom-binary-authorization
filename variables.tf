variable "project_id" {}
variable "binauth_name" {}
variable "region" {}
variable "ascii_armored_pgp_public_key_file" {}
variable "cluster_name" {}
variable "whitelist_names" {
    type = list
}
variable "enforcement_mode" {}
variable "evaluation_mode" {}
