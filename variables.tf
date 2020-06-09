#variable login_approle_role_id {}
#variable login_approle_secret_id {}

variable provider_url {
  type    = string
  default = "https://localhost:8200"
}

variable parent_namespace_name {
  type    = string
  default = "root"
}

variable namespace_policies {
  type = list
  default = []
}

variable namespace_name {
  type = string
}

variable ldap_path {
  type    = string
  default = ""
}

variable ldap_url {
  type    = string
  default = "ldaps://dc-01.example.org"
}

variable ldap_userdn {
  type    = string
  default = "OU=Users,OU=Accounts,DC=example,DC=org"
}

variable ldap_userattr {
  type    = string
  default = "sAMAccountName"
}

variable ldap_upndomain {
  type    = string
  default = "EXAMPLE.ORG"
}

variable ldap_discoverdn {
  type    = bool
  default = false
}

variable ldap_groupdn {
  type    = string
  default = "OU=Groups,DC=example,DC=org"
}

variable ldap_groupfilter {
  type    = string
  default = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
}

variable ldap_provider {
  type    = string
  default = ""
}

variable ldap_groups {
  type    = list
  default = []
}

variable pki_path {
  type    = string
  default = ""
}

variable pki_seal_wrap {
  type    = bool
  default = false
}

variable pki_default_lease_ttl_seconds {
  type    = number
  default = 3600
}

variable pki_max_lease_ttl_seconds {
  type    = number
  default = 86400
}

variable pki_role_name {
  type    = string
  default = "pki_role"
}

variable pki_role_allow_any_name {
  type    = bool
  default = false
}

variable pki_role_allow_bare_domains {
  type    = bool
  default = false
}

variable pki_role_allow_glob_domains {
  type    = bool
  default = false
}

variable pki_role_allow_ip_sans {
  type    = bool
  default = true
}

variable pki_role_allow_localhost {
  type    = bool
  default = true
}

variable pki_role_allow_subdomains {
  type    = bool
  default = false
}

variable pki_role_allowed_domains {
  type    = list
  default = []
}

variable pki_role_allowed_other_sans {
  type    = list
  default = []
}

variable pki_role_allowed_uri_sans {
  type    = list
  default = []
}

variable pki_role_basic_constraints_valid_for_non_ca {
  type    = bool
  default = false
}

variable pki_role_client_flag {
  type    = bool
  default = true
}

variable pki_role_code_signing_flag {
  type    = bool
  default = false
}

variable pki_role_email_protection_flag {
  type    = bool
  default = false
}

variable pki_role_enforce_hostnames {
  type    = bool
  default = true
}

variable pki_role_generate_lease {
  type    = bool
  default = false
}

variable pki_role_key_bits {
  type    = number
  default = 2048
}

variable pki_role_key_type {
  type    = string
  default = "rsa"
}

variable pki_role_no_store {
  type    = bool
  default = false
}

variable pki_role_require_cn {
  type    = bool
  default = true
}

variable pki_role_server_flag {
  type    = bool
  default = true
}

variable pki_role_use_csr_common_name {
  type    = bool
  default = true
}

variable pki_role_use_csr_sans {
  type    = bool
  default = true
}

variable pki_csr_type {
  type    = string
  default = "internal"
}

variable pki_csr_common_name {
  type    = string
  default = ""
}

variable pki_csr_alt_names {
  type    = list
  default = []
}

variable pki_csr_ip_sans {
  type    = list
  default = []
}

variable pki_csr_uri_sans {
  type    = list
  default = []
}

variable pki_csr_other_sans {
  type    = list
  default = []
}

variable pki_csr_format {
  type    = string
  default = "pem"
}

variable pki_csr_private_key_format {
  type    = string
  default = "der"
}

variable pki_csr_key_type {
  type    = string
  default = "rsa"
}

variable pki_csr_key_bits {
  type    = number
  default = 2048
}

variable pki_csr_exclude_cn_from_sans {
  type    = bool
  default = false
}

variable pki_csr_ou {
  type    = string
  default = ""
}

variable pki_csr_organization {
  type    = string
  default = ""
}

variable pki_csr_country {
  type    = string
  default = ""
}

variable pki_csr_locality {
  type    = string
  default = ""
}

variable pki_csr_province {
  type    = string
  default = ""
}

variable pki_csr_street_address {
  type    = string
  default = ""
}

variable pki_csr_postal_code {
  type    = string
  default = ""
}

variable pki_csr_sign_ca_pki {
  type    = string
  default = ""
}

variable pki_csr_sign_ca_common_name {
  type    = string
  default = ""
}

variable pki_csr_sign_ca_use_csr_values {
  type    = bool
  default = true
}

#variable pki_signed_ca_ {
#}

variable kv_path {
  type    = string
  default = ""
}

variable ssh_mount_path {
  type    = string
  default = "ssh"
}