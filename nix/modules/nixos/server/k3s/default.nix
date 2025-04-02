{
  lib,
  config,
  pkgs,
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

    swarm.esh.templates.k3sEnvironment = {
      # Split up the cluster and service CIDRs between the available range
      template = with pkgs; ''
        <%
          parentCidr=$(${ndisc6}/bin/rdisc6 -1q ${config.swarm.hardware.networking.networkDevice});
          prefixLengths=(${toString config.swarm.server.k3s.clusterCidrPrefixLength})
          hostIds=(${concatStringsSep " " lib.swarm.allMachineHostIds})
          splitCidrs=$( ${swarm.ipv6-splitter}/bin/ipv6-splitter $parentCidr ''${prefixLengths[@]} ''${hostIds[@]})
          cidrs=($(
            awk -f ${writeText "ipv6-splitter.awk" ''
          BEGIN { found_match = 0 }
          /Seed: ${config.networking.hostId}/ { found_match = 1; next }
          found_match && /^[[:space:]]/ { print }
          found_match && /^[^[:space:]]/ { exit }
        ''} <<< ''${splitCidrs}
          ))
        %>
        parentCidr=<%= ''${parentCidr} %>
        cidrs=<%= ''${cidrs} %>
        splitCidrs=<%= ''${splitCidrs} %>
        clusterCidr=<%= ''${cidrs:0:1} %>
      '';
      destination = "/etc/rancher/k3s/cidrs";
    };

    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--disable metrics-server"
        "--cluster-cidr=\${clusterCidr}"
        "--service-cidr='fd01::/112'"
        "--flannel-backend=none"
        "--kube-controller-manager-arg=node-cidr-mask-size=${toString config.swarm.server.k3s.clusterCidrPrefixLength}"
        (concatStringsSep " " (concatMap (san: ["--tls-san" san]) config.swarm.server.k3s.san))
      ];
      environmentFile = config.swarm.esh.templates.k3sEnvironment.destination;
      tokenFile = config.sops.secrets.k3s-token.path;
      clusterInit = config.swarm.server.k3s.clusterInit;
    };

    systemd.services.k3s = {
      after = [
        config.systemd.services.k3sEnvironment-swarm-template.name
      ];
      wants = [
        config.systemd.services.k3sEnvironment-swarm-template.name
      ];
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
          from = 2397;
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
  };
}
