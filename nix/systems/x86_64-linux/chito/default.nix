{
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
    ./templates/certs.nix
  ];

  swarm = {
    hardware = {
      nvidia.enable = true;

      networking = {
        hostId = "d86dc3dc";
        networkDevice = "enp5s0";
      };
    };
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    systemdboot.enable = true;
    fs.type = "zfs";
    ssh.enable = true;
    server = {
      k3s = {
        enable = false;
        zfsStorageDisks = [
          "/dev/zvol/zroot/mayastor"
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
        enable = true;
        awsCredentialsFile = config.sops.secrets.route53-acme-credentials.path;
        hostedZoneId = "Z004213625PGR7UVYSB0C";
        awsRegion = "ca-central-1";
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.enableAllTerminfo = true;

  # TODO(rhoddy): This just doesn't fucking work. It doesn't persist either, even with /.keep_sshd. I don't know why.
  # Maybe a tmpfs issue? Or a kernel module issue? I don't know.
  # boot = {
  #   kernelParams = [
  #     "ip=dhcp"
  #   ];
  #   initrd = {
  #     availableKernelModules = ["igb" "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  #     network = {
  #       enable = true;
  #       ssh = {
  #         enable = true;
  #         port = 23;
  #         authorizedKeys = swarm.publicKeys;
  #         hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
  #         shell = "/bin/cryptsetup-askpass";
  #       };
  #     };
  #     preDeviceCommands = ''
  #       touch /.keep_sshd
  #     '';
  #   };
  # };
  boot = {
    kernelModules = ["kvm-amd"];
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C93D-E931";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/nix" = {
    device = "zroot/root/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zroot/root/home";
    fsType = "zfs";
  };

  fileSystems."/var/log" = {
    device = "/nix/persist/var/log";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/etc/secrets" = {
    device = "/nix/persist/etc/secrets";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
  };

  system.stateVersion = "24.11";
}
