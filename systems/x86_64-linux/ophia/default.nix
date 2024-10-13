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
}: {
  swarm = {
    hardware = {
      nvidia.enable = true;
      networking.hostId = "36aa1853";
    };
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    audio.enable = true;
    fs.type = "zfs";
    signal.enable = true;
    gaming.steam.enable = true;
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];

  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    defaultGateway6 = {
      address = "fe00::1";
      interface = "enp6s0";
    };
    interfaces.enp6s0.ipv6.addresses = [ {
      address = "2601:197:4400:3f9::cafe:beef";
      prefixLength = 64;
    } ];
  };

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/mnt/coldstorage" = {
    device = "cpool/coldstorage";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F614-4162";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "24.11";
}
