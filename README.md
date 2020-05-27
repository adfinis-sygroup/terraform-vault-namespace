# terraform-vault-namespace

*** WIP ***

Example structure of namespaces (root containing a pki secrets engine and ldap auth method configured manually):
```
root
  root_pki
  root_ldap

namespaces
  test1
    ldap
    kv
    standard set of policies
    
    test2
      pki intermediate ca signed by root pki
      standard set of policies

  test3
    standard set of policies
    mapping of ldap users to namespace groups and policies
```

main.tf
```
locals {
  policylist = fileset("policies/", "*.hcl")
}

module "test1" {
  source = "github.com/adfinis-sygroup/terraform-vault-namespace"
  namespace_policies = policylist
  namespace_name = "test1"
  kv_path = "kv"
  ldap_path = "ldap"
  ldap_url = "ldaps://dc-01.example.org"
  ldap_userdn = "OU=Users,OU=Accounts,DC=example,DC=org"
  ldap_userattr = "sAMAccountName"
  ldap_upndomain = "EXAMPLE.ORG"
  ldap_groupdn = "OU=Groups,DC=example,DC=org"
  ldap_groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
}

module "test2" {
  source = "github.com/adfinis-sygroup/terraform-vault-namespace"
  namespace_policies = policylist
  namespace_name = "test2"
  parent_namespace_name = "test1"
  pki_path = "pki"
  pki_csr_sign_ca_pki = "root_pki"
  pki_seal_wrap = true
  pki_csr_common_name = "Testytest24"
}

module "test3" {
  source = "github.com/adfinis-sygroup/terraform-vault-namespace"
  namespace_policies = local.policylist
  ldap_groups = local.policylist
  ldap_provider = "root_ldap"
  parent_namespace_name = "root"
  namespace_name = "test3"
}
```
