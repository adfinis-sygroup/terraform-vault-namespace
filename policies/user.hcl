# List, create, update, and delete key/value secrets
path "secret/kv/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
