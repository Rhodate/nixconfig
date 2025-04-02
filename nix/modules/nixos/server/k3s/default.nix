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
      type = types.listOf (types.str);
      default = [];
    };
    clusterCidrPrefixLength = mkOption {
      description = "k3s CIDR prefix length";
      type = types.int;
      default = 80;
    };
    clusterDns = mkOption {
      description = "k3s DNS";
      type = types.str;
      default = "k8s.rhodate.com";
    };
  };
  config = mkIf config.swarm.server.k3s.enable {
    sops = {
      secrets = {
        k3s-token = {
          format = "binary";
          sopsFile = snowfall.fs.get-file "secrets/common/k3s.token";
        };
      };
    };

    environment.etc."rancher/k3s/registries.yaml".text = ''
      mirrors:
        "*":
    '';

    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = [
        "--disable metrics-server"
        "--flannel-ipv6-masq"
        "--cluster-cidr='fd02::/56'"
        "--service-cidr='fd01::/112'"
        "--server=https://${config.swarm.server.k3s.clusterDns}:6443"
        (concatStringsSep " " (concatMap (san: ["--tls-san" san]) config.swarm.server.k3s.san))
        "--tls-san=${config.swarm.server.k3s.clusterDns}"
      ];
      tokenFile = config.sops.secrets.k3s-token.path;
      clusterInit = config.swarm.server.k3s.clusterInit;
      manifests."tfstate-namespace" = {
        content = {
          apiVersion = "v1";
          kind = "Namespace";
          metadata = {
            name = "tfstate";
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
        443
        5001
        6443
      ];
      allowedTCPPortRanges = [
        {
          from = 2379;
          to = 2380;
        }
      ];
      allowedUDPPorts = [
        8472
        51821
      ];
    };

    fileSystems."/var/lib/rancher/k3s" = {
      device = "/nix/persist/var/lib/rancher/k3s";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/etc/rancher/k3s" = {
      device = "/nix/persist/etc/rancher/k3s";
      fsType = "none";
      options = ["bind"];
    };
  };
}
