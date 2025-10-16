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
    clusterDns = mkOption {
      description = "k3s DNS";
      type = types.str;
      default = config.swarm.hardware.networking.wireguard.hosts.nuko-2.ip;
    };
    zfsStorageDisks = mkOption {
      description = "path to k3s ZFS storage disks";
      type = types.listOf (types.str);
      default = [];
    };
    podCidr = mkOption {
      description = "k3s pod cidr";
      type = types.str;
      default = "10.42.0.0/16";
    };
    serviceCidr = mkOption {
      description = "k3s service cidr";
      type = types.str;
      default = "10.43.0.0/16";
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
        "--flannel-backend=host-gw"
        "--flannel-iface=wg0"
        "--kubelet-arg=--pod-cidr=${config.swarm.hardware.networking.wireguard.hosts.${config.networking.hostName}.podCIDR}"
        "--service-cidr=${config.swarm.server.k3s.serviceCidr}"
        "--node-ip=${config.swarm.hardware.networking.wireguard.ip}"
        (mkIf (!config.swarm.server.k3s.clusterInit) "--server=https://${config.swarm.server.k3s.clusterDns}:6443")
        "--kube-apiserver-arg=\"admission-control-config-file=${./psa.yaml}\""
        "--secrets-encryption"
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

    networking.firewall.interfaces.wg0 = {
      allowedTCPPorts = [ 
        6443
        10250
        443
        5001
        2379
        2380
      ];
      allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
      allowedUDPPorts = [
        8472
        51821
      ];
    };

    systemd.services.user-kubeconfig = {
      description = "Copy kubeconfig to user home";
      after = ["k3s.service"];
      wants = ["k3s.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
      };
      script = ''
        mkdir -p /home/${swarm.user}/.kube
        chown ${swarm.user}:${config.users.users.${swarm.user}.group} /home/${swarm.user}/.kube
        rm -f /home/${swarm.user}/.kube/config
        cp /etc/rancher/k3s/k3s.yaml /home/${swarm.user}/.kube/config
        chown ${swarm.user}:${config.users.users.${swarm.user}.group} /home/${swarm.user}/.kube/config
      '';
      wantedBy = ["multi-user.target"];
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
