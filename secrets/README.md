# Secrets Recovery

The file [recovery.key.age](recovery.key.age) can be used to recover the private keys of the instances in this cluster, as encrypted in the [recovery](recovery/) directory.

## Creating the recovery key

```bash
age-keygen -o recovery.key
age -p recovery.key > recovery.key.age
```

## Decrypting 

```bash
age -d recovery.key.age > recovery.key
SOPS_AGE_KEY_FILE=recovery.key sops --decrypt {file}
```
