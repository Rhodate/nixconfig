{
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
  ];

  swarm = {
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    systemdboot.enable = true;
    fs.type = "zfs";
    ssh.enable = true;
    server = {
      k3s = {
        enable = true;
        zfsStorageDisks = [
          "/dev/zvol/rpool/mayastor"
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
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.enableAllTerminfo = true;

  boot = {
    kernelModules = ["kvm-amd"];
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/esp";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/nix" = {
    device = "rpool/nix";
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
