# Provisioning process

```zsh

# partition disks first, and create boot partition fs

BOOT_PART=/dev/whatever
ZFS_PART=/dev/whatever

# Set up zfs for nix and mayastor

zpool create -o ashift=12 -o autotrim=on -R $ZFS_PART -O acltype=posixacl -O canmount=off -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=none rpool

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

# Once the system is configured in this repo. Be sure to replace the hostname
nixos-install --root /mnt/ --flake https://github.com/Rhodate/nixconfig/archive/master.tar.gz#nuko

```
