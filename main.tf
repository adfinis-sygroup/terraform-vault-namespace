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

resource "vault_pki_secret_backend" "pki" {
  depends_on                = [vault_namespace.namespace]
  path                      = var.pki_path
  default_lease_ttl_seconds = var.pki_default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.pki_max_lease_ttl_seconds
  count                     = var.pki_path != "" ? 1 : 0
}

resource "vault_pki_secret_backend_role" "role" {
  depends_on = [vault_pki_secret_backend.pki]
  backend    = vault_pki_secret_backend.pki[count.index].path
  name       = var.pki_role_name
  count      = var.pki_path != "" ? 1 : 0
}

resource "vault_pki_secret_backend_config_ca" "intermediate" {
  depends_on = [vault_pki_secret_backend.pki]
  backend    = vault_pki_secret_backend.pki[count.index].path
  pem_bundle = var.pki_pem_bundle
  count      = var.pki_path != "" && var.pki_pem_bundle != "" ? 1 : 0
}
