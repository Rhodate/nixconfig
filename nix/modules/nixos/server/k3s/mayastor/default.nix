{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  mayastor = "mayastor";
in {
  config = mkIf config.swarm.server.k3s.enable {
    # Enable K3s service
    services.k3s = {
      extraFlags = mkAfter ["--node-label openebs.io/engine=mayastor"];
      manifests = listToAttrs (map (
          zfsStorageDisk: rec {
            name = "diskpool-${replaceStrings ["/" "."] ["-" "-"] zfsStorageDisk}";
            value = {
              content = {
                apiVersion = "openebs.io/v1beta3";
                kind = "DiskPool";
                metadata = {
                  name = "${name}";
                  namespace = mayastor;
                };
                spec = {
                  node = config.networking.hostName;
                  disks = ["uring://${zfsStorageDisk}"];
                };
              };
            };
          }
        )
        config.swarm.server.k3s.zfsStorageDisks);
      autoDeployCharts.mayastor = {
        repo = "https://openebs.github.io/mayastor-extensions";
        name = mayastor;
        version = "0.0.0";
        hash = "sha256-h/V2NLXgF9BfeHRe+H2P918Qe03PifBla3XlfpLwtso=";
        targetNamespace = mayastor;
        createNamespace = true;
        values = {
          etcd = {
            affinity = {};
            replicaCount = 2;
          };
          obs.callhome.enabled = false;
          eventing.enabled = false;
        };
      };
    };

    swarm.hardware.networking.firewall = {
      localTcpPorts = {
        Mayastor-GRPC = [10124];
        Mayastor-NVMe-oF = [8420 4421];
      };
    };

    # Required system packages for Longhorn
    environment.systemPackages = with pkgs; [
      zfs
    ];

    # Ensure the needed kernel modules are loaded
    boot.supportedFilesystems = ["zfs"];
    boot.kernel.sysctl."vm.nr_hugepages" = "1024";
    boot.kernelParams = ["nvme_core.multipath=Y"];
    boot.kernelModules = ["iscsi_tcp" "zfs" "nvme_tcp" "nvme_rdma" "nvme_loop"];
  };
}
