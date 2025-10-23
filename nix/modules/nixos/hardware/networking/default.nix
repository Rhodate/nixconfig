{
  config,
  lib,
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
    networkDevice = mkOption {
      description = "The network device to use";
      type = str;
      default = "eth0";
    };
  };

  config = let
    cfg = config.swarm.hardware.networking;
  in
    mkIf cfg.enable {
      networking = {
        hostId = cfg.hostId;
        nat.enable = true;
        nat.enableIPv6 = true;
        nat.externalInterface = cfg.networkDevice;
        firewall.enable = true;
      };
    };
}
