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
    linkLocalIpv6Cidr = mkOption {
      description = "The link local ipv6 cidr";
      type = str;
      default = "fe80::/64";
    };
    enableIpv6Privacy = mkOption {
      description = "Enable random ipv6 privacy addresses";
      type = bool;
      default = true;
    };
  };

  config = let
    cfg = config.swarm.hardware.networking;
  in
    mkIf cfg.enable {
      networking = {
        hostId = cfg.hostId;
        enableIPv6 = true;
        interfaces.${cfg.networkDevice}.tempAddress = if cfg.enableIpv6Privacy then "default" else "disabled";
      };

      boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = "1";
      boot.kernel.sysctl."net.ipv6.conf.default.forwarding" = "1";
      boot.kernel.sysctl."net.ipv6.conf.all.accept_ra" = "2";
    };
}
