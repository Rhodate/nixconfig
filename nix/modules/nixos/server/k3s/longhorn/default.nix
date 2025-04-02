{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = mkIf config.swarm.server.k3s.enable {
    # Enable K3s service
    services.k3s = {
      # Ensure open-iscsi is available for Longhorn
      extraFlags = mkAfter [ "--node-label 'node.longhorn.io/create-default-disk=true'" "--kubelet-arg=volume-plugin-dir=/var/lib/kubelet/volumeplugins"];

      # Deploy Longhorn automatically
      autoDeployCharts.longhorn = {
        repo = "https://charts.longhorn.io";
        name = "longhorn";
        version = "1.8.1";
        hash = "sha256-cc3U1SSSb8LxWHAzSAz5d97rTfL7cDfxc+qOjm8c3CA=";
        targetNamespace = "longhorn-system";
        createNamespace = true;
        values = {
          persistence = {
            defaultClass = true;
          };
          defaultSettings = {
            defaultDataPath = "/var/lib/longhorn";
            replicaAutoBalance = "best-effort";
            storageOverProvisioningPercentage = 200;
            storageMinimalAvailablePercentage = 10;
            iscsiToolsPath = "/usr/bin";
            backupToolsPath = "/usr/bin";
            mountpointOperationTimeoutSeconds = 300;
          };
          enableIPv6 = true;
          network = {
            dualStackIPv6Primary = true;
          };
          ingress = {
            enabled = false;
          };
          resources = {
            requests = {
              cpu = "100m";
              memory = "128Mi";
            };
          };
          longhornManager = {
            priorityClass = "system-node-critical";
            privileged = true;
            hostPID = true;
          };
          longhornDriver = {
            priorityClass = "system-node-critical";
          };
          longhornUI = {
            priorityClass = "system-cluster-critical";
          };
        };
      };
    };

    # Required system packages for Longhorn
    environment.systemPackages = with pkgs; [
      openiscsi
      nfs-utils
      util-linux
      bash
    ];

    # Enhanced openiscsi configuration
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.rhodate:${config.networking.hostId}";
      extraConfig = ''
        node.startup = automatic
        node.session.auth.authmethod = None
      '';
    };

    # Create symbolic links to iscsiadm in standard paths
    system.activationScripts.longhorn-iscsi-paths = {
      text = ''
        # Create standard paths that Longhorn might look for
        mkdir -p /usr/bin /usr/local/bin /bin
        
        # Create symlinks to iscsiadm in multiple potential locations
        ln -sf ${pkgs.openiscsi}/bin/iscsiadm /usr/bin/iscsiadm
        ln -sf ${pkgs.openiscsi}/bin/iscsiadm /usr/local/bin/iscsiadm
        ln -sf ${pkgs.openiscsi}/bin/iscsiadm /bin/iscsiadm
        
        # Also ensure iscsid is linked
        ln -sf ${pkgs.openiscsi}/bin/iscsid /usr/bin/iscsid
        ln -sf ${pkgs.openiscsi}/bin/iscsid /usr/local/bin/iscsid
        ln -sf ${pkgs.openiscsi}/bin/iscsid /bin/iscsid
      '';
      deps = [];
    };    # Set up longhorn data directory to symlink to persist directory
    fileSystems."/var/lib/longhorn" = {
      device = "/nix/persist/var/lib/longhorn";
      fsType = "none";
      options = ["bind"];
    };
    
    # Ensure the volume plugin directory exists
    system.activationScripts.kubelet-volumeplugins = {
      text = ''
        mkdir -p /var/lib/kubelet/volumeplugins
      '';
      deps = [];
    };

    # Ensure the needed kernel modules are loaded
    boot.kernelModules = ["iscsi_tcp" "nfs"];
  };
}
