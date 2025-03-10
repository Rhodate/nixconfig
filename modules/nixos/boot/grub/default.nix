{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.grub = with types; {
    enable = mkOption {
      description = "Use grub as the bootloader";
      type = types.bool;
      default = false;
    };
  };

  config = let
    cfg = config.swarm.grub;
  in
    mkIf cfg.enable {
      boot.loader = {
        systemd-boot.enable = false;
        grub = {
          enable = true;
          device = "nodev";
          useOSProber = true;
          efiSupport = true;
          zfsSupport = true;
          fontSize = 11;
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    };
}
