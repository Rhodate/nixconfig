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
      default = [
        "${config.networking.hostName}.${swarm.domainName}"
        "${swarm.domainName}"
      ];
    };
    clusterCidr = mkOption {
      description = "k3s CIDR prefix length";
      type = types.str;
      default = "fd02::/56";
    };
    serviceCidr = mkOption {
      description = "k3s service CIDR prefix length";
      type = types.str;
      default = "fd01::/112";
    };
    clusterDns = mkOption {
      description = "k3s DNS";
      type = types.str;
      default = "k8s.${swarm.domainName}";
    };
    zfsStorageDisks = mkOption {
      description = "path to k3s ZFS storage disks";
      type = types.listOf (types.str);
      default = [];
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
        "--cluster-cidr='${config.swarm.server.k3s.clusterCidr}'"
        "--service-cidr='${config.swarm.server.k3s.serviceCidr}'"
        (mkIf (!config.swarm.server.k3s.clusterInit) "--server=https://${config.swarm.server.k3s.clusterDns}:6443")
        (concatStringsSep " " (concatMap (san: ["--tls-san" san]) config.swarm.server.k3s.san))
        "--kube-apiserver-arg=\"admission-control-config-file=${./psa.yaml}\""
        "--secrets-encryption"
        "--tls-san=${config.swarm.server.k3s.clusterDns}"
      ];
      tokenFile = config.sops.secrets.k3s-token.path;
      clusterInit = config.swarm.server.k3s.clusterInit;
      manifests = {
        tfstate-namespace.content = {
          apiVersion = "v1";
          kind = "Namespace";
          metadata = {
            name = "tfstate";
          };
        };
      };
    };

    systemd.services.user-kubeconfig = {
      description = "Copy kubeconfig to user home";
      after = ["k3s.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
      };
      script = ''
        mkdir -p /home/${swarm.user}/.kube
        chown ${swarm.user}:${config.users.users.${swarm.user}.group} /home/${swarm.user}/.kube
        rm -f /home/${swarm.user}/.kube/config
        ln -s /etc/rancher/k3s/k3s.yaml /home/${swarm.user}/.kube/config
        chown ${swarm.user}:${config.users.users.${swarm.user}.group} /home/${swarm.user}/.kube/config
      '';
      wantedBy = ["multi-user.target"]; # Enable the service
    };

    swarm.hardware.networking.firewall = {
      localTcpPorts.k3s = [
        6443
        10250
        443
        5001
        2379
        2380
      ];

      localUdpPorts.k3s = [
        8472
        51821
      ];

      extraLocalCidrs = strings.splitString "," (config.swarm.server.k3s.clusterCidr);
    };

    boot.kernel.sysctl = {
      "vm.panic_on_oom" = "0";
      "vm.overcommit_memory" = "1";
      "kernel.panic" = "10";
      "kernel.panic_on_oops" = "1";
    };

    fileSystems."/var/lib/rancher/k3s" = {
      device = "/nix/persist/var/lib/rancher/k3s";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/var/local" = {
      device = "/nix/persist/var/local";
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
