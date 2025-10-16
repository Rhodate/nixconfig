{
  lib,
  config,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
  ];

  swarm = {
    hardware = {
      nvidia.enable = false;
      amdgpu.enable = true;
      networking = {
        hostId = "36aa1853";
        networkDevice = "enp14s0";
        wireguard = {
          enable = true;
          privateKeyFile = "/nix/secrets/wireguard.private";
        };
      };
      input-remapper.enable = true;
    };
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    ai = {
      ollama = {
        enable = false;
        rocmOverrideGfx = "11.0.0";
      };
    };
    audio.enable = true;
    fs.type = "zfs";
    gaming.steam.enable = true;
    syncthing = {
      enable = false;
      keyFile = config.sops.secrets.syncthing-key.path;
      certFile = config.sops.secrets.syncthing-cert.path;
    };
    management = {
      enable = true;
      flakePath = "/home/${swarm.user}/swarm.flake";
      sw.enable = true;
    };
    desktop.hyprland.enable = true;
    grub.enable = true;
    server = {
      k3s = {
        enable = true;
        clusterInit = false;
        zfsStorageDisks = [
          "/dev/disk/by-id/nvme-eui.0025385c2140361b"
        ];
      };
      services.route53-dyndns = {
        enable = true;
        hostedZoneId = "Z004213625PGR7UVYSB0C";
        awsCredentialsFile = config.sops.secrets.route53-dyndns-credentials.path;
        records = {
          git = {};
          k8s = {};
        };
      };
      acme = {
        enable = false;
        awsCredentialsFile = config.sops.secrets.route53-acme-credentials.path;
        hostedZoneId = "Z004213625PGR7UVYSB0C";
        awsRegion = "ca-central-1";
      };
    };
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "amdgpu"];

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F614-4162";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  system.stateVersion = "24.11";
}
