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
    role = mkOption {
      description = "k3s role";
      type = types.str;
      default = "server";
    };
    zfsStorageDisks = mkOption {
      description = "path to k3s ZFS storage disks";
      type = types.listOf (types.str);
      default = [];
    };
    podCidr = mkOption {
      description = "k3s pod cidr";
      type = types.str;
      default = "10.42.0.0/16,fc00:10::/56";
    };
    serviceCidr = mkOption {
      description = "k3s service cidr";
      type = types.str;
      default = "10.43.0.0/16,fc00:20::/108";
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
      role = config.swarm.server.k3s.role;
      extraFlags = mkMerge [
        (mkIf (config.swarm.server.k3s.role == "server") [
          "--disable metrics-server"
          "--disable traefik"
          "--flannel-backend=vxlan"
          "--service-cidr=${config.swarm.server.k3s.serviceCidr}"
          "--cluster-cidr=${config.swarm.server.k3s.podCidr}"
          "--kube-apiserver-arg=\"admission-control-config-file=${./psa.yaml}\""
          "--secrets-encryption"
          "--kube-apiserver-arg=feature-gates=MutatingAdmissionPolicy=true"
          "--kube-apiserver-arg=\"--runtime-config=admissionregistration.k8s.io/v1beta1=true\""
        ])
        [
          (mkIf (!config.swarm.server.k3s.clusterInit) "--server=https://${config.swarm.server.k3s.clusterDns}:6443")
          "--flannel-iface=wg0"
          "--node-ip=${config.swarm.hardware.networking.wireguard.ip},${config.swarm.hardware.networking.wireguard.ipv6}"
        ]
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
