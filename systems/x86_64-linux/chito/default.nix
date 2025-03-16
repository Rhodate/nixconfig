{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the system system.
  config,
  modulesPath,
  ...
}:
with lib; {
  swarm = {
    hardware = {
      nvidia.enable = true;
      networking.hostId = "d86dc3dc";
    };
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    systemdboot.enable = true;
    fs.type = "zfs";
    ssh.enable = true;
    k3s = {
      enable = true;
      clusterInit = true;
    };
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  security.sudo.wheelNeedsPassword = false;

  environment.enableAllTerminfo = true;

  boot = {
    kernelModules = ["kvm-amd"];
    kernelParams = [
      "ip=dhcp"
    ];
    initrd = {
      availableKernelModules = ["igb" "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 23;
          authorizedKeys = [swarm.masterSshKey];
          hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
          shell = "/bin/cryptsetup-askpass";
        };
      };
      preDeviceCommands = ''
        touch /.keep_sshd
      '';
    };
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

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "24.11";
}
