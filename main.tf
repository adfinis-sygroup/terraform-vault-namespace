provider "vault" {
  version   = "~> 2.11"
  address   = var.provider_url
  alias     = "root"
}

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
  address   = var.provider_url
  alias     = "parent"
  namespace = var.parent_namespace_name
}

provider "vault" {
  version   = "~> 2.11"
  address   = var.provider_url
  alias     = "ns"
  namespace = join("/", [var.parent_namespace_name != "root" ? var.parent_namespace_name : "", vault_namespace.namespace.path])
}

resource "vault_namespace" "namespace" {
  path     = var.namespace_name
  provider = vault.parent
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

data "vault_auth_backend" "ldap" {
  depends_on  = [vault_ldap_auth_backend.ldap]
  path = var.ldap_provider
  provider = vault.root
}

resource "vault_identity_group" "root_group" {
  count = length(var.ldap_groups) > 0 ? length(var.ldap_groups) : 0

  depends_on  = [vault_ldap_auth_backend.ldap]
  name     = join("-", [var.ldap_provider, split(".", var.ldap_groups[count.index])[0]])
  type     = "external"
  provider = vault.root
}

resource "vault_identity_group_alias" "root_group_alias" {
  count = length(var.ldap_groups) > 0 ? length(var.ldap_groups) : 0

  depends_on  = [vault_identity_group.root_group]
  name           = split(".", var.ldap_groups[count.index])[0]
  mount_accessor = data.vault_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.root_group[count.index].id
  provider       = vault.root
}

resource "vault_identity_group" "group" {
  count = length(var.ldap_groups) > 0 ? length(var.ldap_groups) : 0

  depends_on  = [vault_identity_group_alias.root_group_alias]
  name             = split(".", var.ldap_groups[count.index])[0]
  policies         = [var.namespace_policies[count.index]]
  member_group_ids = vault_identity_group.root_group[count.index].id
  provider         = vault.ns
}

resource "vault_mount" "pki" {
  count                     = var.pki_path != "" ? 1 : 0

  depends_on                = [vault_namespace.namespace]
  provider                  = vault.ns
  path                      = var.pki_path
  type                      = "pki"
  default_lease_ttl_seconds = var.pki_default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.pki_max_lease_ttl_seconds
  seal_wrap                 = var.pki_seal_wrap
}

resource "vault_pki_secret_backend_role" "role" {
  count                              = var.pki_path != "" ? 1 : 0

  depends_on                         = [vault_mount.pki]
  provider                           = vault.ns
  backend                            = vault_mount.pki[count.index].path
  name                               = var.pki_role_name
  allow_any_name                     = var.pki_role_allow_any_name
  allow_bare_domains                 = var.pki_role_allow_bare_domains
  allow_glob_domains                 = var.pki_role_allow_glob_domains
  allow_ip_sans                      = var.pki_role_allow_ip_sans
  allow_localhost                    = var.pki_role_allow_localhost
  allow_subdomains                   = var.pki_role_allow_subdomains
  allowed_domains                    = var.pki_role_allowed_domains
  allowed_other_sans                 = var.pki_role_allowed_other_sans
  allowed_uri_sans                   = var.pki_role_allowed_uri_sans
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

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_ca_csr" {
  count = var.pki_path != "" ? 1 : 0

  depends_on           = [vault_mount.pki]
  provider             = vault.ns
  backend              = vault_mount.pki[count.index].path
  type                 = var.pki_csr_type
  common_name          = var.pki_csr_common_name
  alt_names            = var.pki_csr_alt_names
  ip_sans              = var.pki_csr_ip_sans
  uri_sans             = var.pki_csr_uri_sans
  other_sans           = var.pki_csr_other_sans
  format               = var.pki_csr_format
  private_key_format   = var.pki_csr_private_key_format
  key_type             = var.pki_csr_key_type
  key_bits             = var.pki_csr_key_bits
  exclude_cn_from_sans = var.pki_csr_exclude_cn_from_sans
  ou                   = var.pki_csr_ou
  organization         = var.pki_csr_organization
  country              = var.pki_csr_country
  locality             = var.pki_csr_locality
  province             = var.pki_csr_province
  street_address       = var.pki_csr_street_address
  postal_code          = var.pki_csr_postal_code
}

resource "vault_pki_secret_backend_root_sign_intermediate" "csr_sign_ca" {
  count          = var.pki_path != "" ? 1 : 0

  depends_on     = [vault_pki_secret_backend_intermediate_cert_request.intermediate_ca_csr]
  provider       = vault.parent
  backend        = var.pki_csr_sign_ca_pki
  csr            = vault_pki_secret_backend_intermediate_cert_request.intermediate_ca_csr[count.index].csr
  use_csr_values = var.pki_csr_sign_ca_use_csr_values
  common_name    = var.pki_csr_sign_ca_common_name
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_ca_set_signed" {
  count       = var.pki_path != "" ? 1 : 0

  depends_on  = [vault_pki_secret_backend_root_sign_intermediate.csr_sign_ca]
  backend     = vault_mount.pki[count.index].path
  provider    = vault.ns
  certificate = vault_pki_secret_backend_root_sign_intermediate.csr_sign_ca[count.index].certificate
}
