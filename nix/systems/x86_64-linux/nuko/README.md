# Provisioning process

```zsh

ssh root@ip

# partition disks first, and create boot partition fs. Elided cause fuck you

BOOT_PART=/dev/whatever
ZFS_PART=/dev/whatever

# Set up zfs for nix and mayastor

zpool create -o ashift=12 -o autotrim=on -R /mnt -O encryption=on -O keyformat=passphrase -O acltype=posixacl -O canmount=off -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=none rpool $ZFS_PART

zfs create rpool/nix -o canmount=noauto -o mountpoint=legacy
zfs create rpool/mayastor -V 350G

# Create directory structure and mount up filesystems

mount -t tmpfs none /mnt

mkdir -p /mnt/{boot,nix,etc/secrets,var/lib/rancher/k3s,etc/rancher/k3s,var/local}

mount $BOOT_PART /mnt/boot
mount -t zfs rpool/nix /mnt/nix/

mkdir -p /mnt/nix/persist/{etc/secrets,var/lib/rancher/k3s,etc/rancher/k3s,var/local}

mount -o bind /mnt/nix/persist/etc/secrets/ /mnt/etc/secrets/

mount -o bind /mnt/nix/persist/etc/rancher/k3s/ /mnt/etc/rancher/k3s/

mount -o bind /mnt/nix/persist/var/lib/rancher/k3s/ /mnt/var/lib/rancher/k3s/

mount -o bind /mnt/nix/persist/var/local/ /mnt/var/local/


# Create ssh host keys

mkdir /mnt/etc/ssh

ssh-keygen -A -f /mnt

cp -r /mnt/etc/ssh /mnt/nix/persist/etc/secrets/ssh

# Get the age public key for sops. This should be added to `.sops.yaml`, committed, and pushed to the remote repo
cat /mnt/etc/secrets/ssh/ssh_host_ed25519_key.pub | ssh-to-age

```

Create the machine config then build and push to the machine like so:

```zsh

nix build .\#nixosConfigurations.hostname.config.system.build.toplevel --show-trace |& nom
nix-copy-closure --to root@ip ./result
ssh root@ip
nixos-install --no-root-password --root /mnt --system

```
