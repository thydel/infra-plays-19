# Generate ansible config

[ansible-cfg]: https://github.com/thydel/ansible-cfg "github.com repo"

Use [ansible-cfg][]

```
mkdir -p ext
git -C ext clone git@github.com:thydel/ansible-cfg.git
make -C ext/ansible-cfg install
```

Generate config

```
ansible-cfg.mk median
```

Update `.gitignore`

```
ansible-cfg.yml
```

# Define private variables

The `paths.yml` file define relative paths for

- `private_repos_file` a `requirement.yml` like file for private data repos
- `keys_file` to define `default_key`, the default ssh key for private repos
- `workdir` where to clone private data repos

In your `private_repos_file` define choose repos for

- `inventories`
- `password-store` 
- others private requested repos (starting from private `infra-data-repos`)
- Optionnaly define `gpg-store`

# Get private repos

[ansible-get-priv-repos]: https://github.com/thydel/ansible-get-priv-repos "github.com repo"

Use [ansible-get-priv-repos][]

```
git -C ext clone git@github.com:thydel/ansible-get-priv-repos.git
make -C ext/ansible-get-priv-repos install
```

Get repos

```
get-priv-repos.yml
```

`get-priv-repos.yml` use `paths.yml` to access `private_repos_file`,
`keys_file` and `workdir`.


# Generate and install inventories

```
make -C ext/inventories main
rsync -av ext/inventories/inventory .
```
