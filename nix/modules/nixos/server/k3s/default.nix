{
  lib,
  config,
  ...
}:
with lib; {
  options.swarm.server.k3s = {
    enable = mkEnableOption "Whether to enable k3s";
    clusterInit = mkOption {
      description = "Whether to initialize the cluster";
      type = types.bool;
      default = false;
    };
    san = mkOption {
      description = "k3s SANs";
      type = types.listOf(types.str);
      default = [];
    };
  };
  config = mkIf config.swarm.server.k3s.enable {
    sops.secrets.k3s-token = {
      format = "binary";
      sopsFile = snowfall.fs.get-file "secrets/common/k3s.token";
    };
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--debug"
        # map over the san to `--tls-san <san>` for each san, in nix code
        (concatStringsSep " " (concatMap (san: ["--tls-san" san]) config.swarm.server.k3s.san))
      ];
      tokenFile = config.sops.secrets.k3s-token.path;
      clusterInit = config.swarm.server.k3s.clusterInit;
    };

    networking.firewall.allowedTCPPorts = [
      6443
      443
    ];
    networking.firewall.allowedUDPPorts = [
      8472
    ];

    fileSystems."/var/lib/rancher/k3s" = {
      device = "/nix/persist/var/lib/rancher/k3s";
      fsType = "none";
      options = ["bind"];
    };
  };
}
