{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.systemdboot = with types; {
    enable = mkOption {
      description = "Use systemdboot as the bootloader";
      type = types.bool;
      default = false;
    };
  };

  config = let
    cfg = config.swarm.systemdboot;
  in
    mkIf cfg.enable {
      boot.loader = {
        systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    };
}
