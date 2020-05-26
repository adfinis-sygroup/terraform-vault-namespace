#variable login_approle_role_id {}
#variable login_approle_secret_id {}

variable provider_url {
  type    = string
  default = "https://localhost:8200"
}

variable namespace_policies {
  type = list
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

variable pki_path {
  type    = string
  default = ""
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

variable pki_pem_bundle {
  type    = string
  default = ""
}
