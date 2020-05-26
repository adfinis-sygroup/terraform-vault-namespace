provider "vault" {
  version = "~> 2.11"
  #  auth_login {
  #    path = "auth/approle/login"
  #
  #    parameters = {
  #      role_id   = var.login_approle_role_id
  #      secret_id = var.login_approle_secret_id
  #    }
  #  }
  address = var.provider_url
  alias   = "root"
}

resource "vault_namespace" "namespace" {
  path     = var.namespace_name
  provider = vault.root
}

provider "vault" {
  version   = "~> 2.11"
  address   = var.provider_url
  alias     = "ns"
  namespace = vault_namespace.namespace.path
}

resource "vault_policy" "policy" {
  for_each   = toset(var.namespace_policies)
  name       = split(".", each.value)[0]
  policy     = file("policies/${each.value}")
  depends_on = [vault_namespace.namespace]
  provider   = vault.ns
}

resource "vault_ldap_auth_backend" "ldap" {
  depends_on  = [vault_namespace.namespace]
  provider    = vault.ns
  path        = var.ldap_path
  url         = var.ldap_url
  userdn      = var.ldap_userdn
  userattr    = var.ldap_userattr
  upndomain   = var.ldap_upndomain
  discoverdn  = var.ldap_discoverdn
  groupdn     = var.ldap_groupdn
  groupfilter = var.ldap_groupfilter
  count       = var.ldap_path != "" ? 1 : 0
}

resource "vault_mount" "pki" {
  depends_on                = [vault_namespace.namespace]
  provider                  = vault.ns
  path                      = var.pki_path
  type = "pki"
  default_lease_ttl_seconds = var.pki_default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.pki_max_lease_ttl_seconds
  count                     = var.pki_path != "" ? 1 : 0
  seal_wrap = var.pki_seal_wrap
}

resource "vault_pki_secret_backend_role" "role" {
  depends_on = [vault_mount.pki]
  provider   = vault.ns
  backend    = vault_mount.pki[count.index].path
  name       = var.pki_role_name
  count      = var.pki_path != "" ? 1 : 0
  allow_any_name                     = var.pki_role_allow_any_name
  allow_bare_domains                 = var.pki_role_allow_bare_domains
  allow_glob_domains                 = var.pki_role_allow_glob_domains
  allow_ip_sans                      = var.pki_role_allow_ip_sans
  allow_localhost                    = var.pki_role_allow_localhost
  allow_subdomains                   = var.pki_role_allow_subdomains
  basic_constraints_valid_for_non_ca = var.pki_role_basic_constraints_valid_for_non_ca
  client_flag                        = var.pki_role_client_flag
  code_signing_flag                  = var.pki_role_code_signing_flag
  email_protection_flag              = var.pki_role_email_protection_flag
  enforce_hostnames                  = var.pki_role_enforce_hostnames
  generate_lease                     = var.pki_role_generate_lease
  key_bits                           = var.pki_role_key_bits
  key_type                           = var.pki_role_key_type
  no_store                           = var.pki_role_no_store
  require_cn                         = var.pki_role_require_cn
  server_flag                        = var.pki_role_server_flag
  use_csr_common_name                = var.pki_role_use_csr_common_name
  use_csr_sans                       = var.pki_role_use_csr_sans
}

resource "vault_pki_secret_backend_config_ca" "intermediate" {
  depends_on = [vault_mount.pki]
  provider   = vault.ns
  backend    = vault_mount.pki[count.index].path
  pem_bundle = var.pki_ca_pem_bundle
  count      = var.pki_path != "" && var.pki_ca_pem_bundle != "" ? 1 : 0
}


