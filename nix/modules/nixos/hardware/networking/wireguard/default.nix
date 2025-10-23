{
  config,
  lib,
  ...
}:
with lib; let
  hosts = {
    ophia = {
      pubkey = "y3lmjPPBHLz02L+xpRTycjCOXZJbXZK09pDfu9DkuxM=";
      endpoint = "ophia.rhodate.com:51820";
      ip = "10.100.0.1";
      podCIDR = "10.42.2.0/24";
    };
    nuko-1 = {
      pubkey = "yKPYubNj8FlV2Q2bYUM7of0CojaoT245XOUaxbxfXk4=";
      endpoint = "nuko-1.rhodate.com:51820";
      ip = "10.100.0.2";
      podCIDR = "10.42.0.0/24";
    };
    nuko-2 = {
      pubkey = "e9kgSC/tqDNXZ1tos4DyJZCmIk9mT4USc/xcQQGKpD0=";
      endpoint = "nuko-2.rhodate.com:51820";
      ip = "10.100.0.3";
      podCIDR = "10.42.4.0/24";
    };
    nuko-3 = {
      pubkey = "vHqdr1AhbJdz1+DyxlLB8PvUdMjOwcx9/LA63BKCm2Q=";
      endpoint = "nuko-3.rhodate.com:51820";
      ip = "10.100.0.4";
      podCIDR = "10.42.1.0/24";
    };
    venus = {
      pubkey = "ApFcWRA4USpfLkarEtl0KVLeJdLWSuRUJL4+Hj2EegE=";
      endpoint = "venus.rhodate.com:51820";
      ip = "10.100.0.5";
      podCIDR = "10.42.3.0/24";
    };
  };
  peers = filterAttrs (name: peer: name != config.networking.hostName) hosts;
in {
  options.swarm.hardware.networking.wireguard = {
    enable = mkEnableOption "Enables connecting to the internal wireguard vpn";

    privateKeyFile = mkOption {
      type = types.str;
      description = "The path to the wireguard private key";
      default = "/nix/persist/wireguard-keys/private";
    };

    ip = mkOption {
      type = types.str;
      description = "The ip address used for the wireguard interface";
      default = hosts.${config.networking.hostName}.ip;
    };

    hosts = mkOption {
      default = hosts;
    };
  };
  config = mkIf config.swarm.hardware.networking.wireguard.enable {
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nat.internalInterfaces = [ "wg0" ];

    networking.firewall.allowedUDPPorts = [ 51820 ];

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "${hosts.${config.networking.hostName}.ip}/24" ];
        listenPort = 51820;

        privateKeyFile = config.swarm.hardware.networking.wireguard.privateKeyFile;

        # Hack from the wiki. Set persistent keepalive here so it actually connects
        postSetup = mapAttrsToList (name: peer: "wg set wg0 peer ${peer.pubkey} persistent-keepalive 25") peers;
        peers = mapAttrsToList (name: peer: {
          publicKey = peer.pubkey;
          endpoint = peer.endpoint;
          allowedIPs = [
            "${peer.ip}/32"
            (mkIf config.swarm.server.k3s.enable "${peer.podCIDR}")
          ];
        }) peers;
      };
    };
  };
}
