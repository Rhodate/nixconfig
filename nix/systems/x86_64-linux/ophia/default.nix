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
      flakePath = swarm.ophia.flakePath;
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

  system.stateVersion = "24.11";
}
