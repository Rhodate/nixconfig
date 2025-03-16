{
  lib,
  config,
  ...
}:
with lib; {
  options.swarm.k3s = {
    enable = mkEnableOption "Whether to enable k3s";
    clusterInit = mkOption {
      description = "Whether to initialize the cluster";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf config.swarm.k3s.enable {
    sops.secrets.k3s-token = {
      format = "binary";
      sopsFile = lib.swarm.secrets-path + /common/k3s.token;
    };
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--debug"
      ];
      tokenFile = config.sops.secrets.k3s-token.path;
      clusterInit = config.swarm.k3s.clusterInit;
    };

    fileSystems."/var/lib/rancher/k3s" = {
      device = "/nix/persist/var/lib/rancher/k3s";
      fsType = "none";
      options = ["bind"];
    };
  };
}
