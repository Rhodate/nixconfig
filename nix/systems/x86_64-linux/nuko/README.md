# Provisioning process

```zsh

ssh root@ip

# Partition disks

lsblk

export DISK=${disk from lsblk}

parted $DISK mklabel gpt

# Boot partition
parted $DISK -- mkpart esp fat32 1MiB 1GiB
parted $DISK -- set 1 boot on

# Partition for zfs
parted $DISK -- mkpart primary 1GiB 100%

export BOOT_PART=/dev/disk/by-partlabel/esp
export ZFS_PART=/dev/disk/by-partlabel/primary

# Set up zfs for nix and mayastor

zpool create -o ashift=12 -o autotrim=on -R /mnt -O encryption=on -O keyformat=passphrase -O acltype=posixacl -O canmount=off -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=none rpool $ZFS_PART

zfs create rpool/nix -o canmount=noauto -o mountpoint=legacy
zfs create rpool/mayastor -V 350G

# Create directory structure and mount up filesystems

mount -t tmpfs none /mnt

mkdir -p /mnt/{boot,nix,etc/secrets,var/lib/rancher/k3s,etc/rancher/k3s,var/local,var/log}

mount $BOOT_PART /mnt/boot
mount -t zfs rpool/nix /mnt/nix/

mkdir -p /mnt/nix/persist/{etc/secrets,var/lib/rancher/k3s,etc/rancher/k3s,var/local,var/log}

mount -o bind /mnt/nix/persist/etc/secrets/ /mnt/etc/secrets/

mount -o bind /mnt/nix/persist/etc/rancher/k3s/ /mnt/etc/rancher/k3s/

mount -o bind /mnt/nix/persist/var/lib/rancher/k3s/ /mnt/var/lib/rancher/k3s/

mount -o bind /mnt/nix/persist/var/local/ /mnt/var/local/

mount -o bind /mnt/nix/persist/var/log /mnt/var/log


# Create ssh host keys

mkdir /mnt/etc/ssh

ssh-keygen -A -f /mnt

cp -r /mnt/etc/ssh /mnt/nix/persist/etc/secrets/ssh

# Get the age public key for sops. This should be added to `.sops.yaml`, committed, and pushed to the remote repo
cat /mnt/etc/secrets/ssh/ssh_host_ed25519_key.pub | ssh-to-age

```

You can rotate the sops files like so, from the secrets directory. It does catch some files that aren't encrypted, but 🤷
```zsh
for f in **/*; do if [ ! -d $f ]; then sops updatekeys $f; fi; done
```

Create the machine config then build and push to the machine like so:

```zsh

nix build .\#nixosConfigurations.hostname.config.system.build.toplevel --show-trace |& nom
nix-copy-closure --to root@ip ./result

ssh root@ip

nixos-install --no-root-password --root /mnt --system ${system path. last thing copied by nix-copy-closure}

# Don't forget or it'll just fail to boot  
zpool export -a

```
