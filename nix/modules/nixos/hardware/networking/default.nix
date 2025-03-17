{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.hardware.networking = with types; {
    enable = mkOption {
      description = "Enable networking options";
      type = bool;
      default = true;
    };
    hostId = mkOption {
      description = "The host id of this machine";
      type = str;
    };
  };

  config = let
    cfg = config.swarm.hardware.networking;
  in
    mkIf cfg.enable {
      networking.useDHCP = lib.mkDefault true;
      networking.hostId = cfg.hostId;
    };
}
