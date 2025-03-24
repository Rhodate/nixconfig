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
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
  ];

  swarm = {
    hardware = {
      nvidia.enable = false;
      amdgpu.enable = true;
      networking.hostId = "36aa1853";
      input-remapper.enable = true;
    };
    virtualization = {
      enable = true;
      implementation = "docker";
    };
    ai.ollama = {
      enable = true;
      rocmOverrideGfx = "11.0.0";
    };
    audio.enable = true;
    fs.type = "zfs";
    signal.enable = true;
    gaming.steam.enable = true;
    syncthing = {
      enable = true;
      keyFile = config.sops.secrets.syncthing-key.path;
      certFile = config.sops.secrets.syncthing-cert.path;
    };
    management = {
      enable = true;
      sw.enable = true;
    };
    grub.enable = true;
  };

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "amdgpu"];

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/0be106e1-0df2-4121-a350-42dc4a98f5c7";
    }
  ];

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

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "24.11";
}
