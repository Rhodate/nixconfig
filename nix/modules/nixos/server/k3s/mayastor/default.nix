{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  mayastor = "mayastor";
in {
  config = mkIf (config.swarm.server.k3s.enable && (length config.swarm.server.k3s.zfsStorageDisks) > 0) {
    services.k3s = {
      extraFlags = mkAfter ["--node-label openebs.io/engine=mayastor"];
      manifests = listToAttrs (map (
          zfsStorageDisk: rec {
            name = "diskpool-${config.networking.hostName}-${replaceStrings ["/" "."] ["-" "-"] zfsStorageDisk}";
            value = {
              content = {
                apiVersion = "openebs.io/v1beta3";
                kind = "DiskPool";
                metadata = {
                  name = "${name}";
                  namespace = mayastor;
                  labels = {
                    randomValue = "jlfka-dfjas";
                  };
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
        version = "2.9.3";
        hash = "sha256-VM3Fz3Nbrrdt/Bb9/K4rUOnEwKeqFvAj+QNX7dm9VWY=";
        targetNamespace = mayastor;
        createNamespace = true;
        values = {
          obs.callhome.enabled = false;
          eventing.enabled = false;
        };
      };
    };

    # Required system packages for mayastor
    environment.systemPackages = with pkgs; [
      zfs
    ];

    networking.firewall.interfaces.wg0 = {
      allowedTCPPorts = [ 
        10124
        8420
        4421
      ];
    };

    # Ensure the needed kernel modules are loaded
    boot.supportedFilesystems = ["zfs"];
    boot.kernel.sysctl."vm.nr_hugepages" = "1024";
    boot.kernelParams = ["nvme_core.multipath=Y"];
    boot.kernelModules = ["iscsi_tcp" "zfs" "nvme_tcp" "nvme_rdma" "nvme_loop"];
  };
}
