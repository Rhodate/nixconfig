{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.swarm.server.services.ip-watcher;
  networkDevice = config.swarm.hardware.networking.networkDevice;
in {
  options.swarm.server.services.ip-watcher = {
    enable = mkEnableOption "Enable IP Watcher Service";

    dependents = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "The systemd units to restart when an ip change is detected.";
    };

    pollingPeriod = mkOption {
      type = types.int;
      default = 5;
      description = "Polling period in seconds.";
    };

    retryBackoffMax = mkOption {
      type = types.int;
      default = 300;
      description = "Maximum backoff time in seconds for retries.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ip-watcher = {
      name = "ip-watcher.service";
      description = "Watches the primary network device for ip address changes and trigger changes on that";
      after = ["network-online.target" "dynamic-default-firewall.target"];
      wants = ["network-online.target" "dynamic-default-firewall.target"];
      wantedBy = ["multi-user.target"];
      unitConfig = {
        StartLimitBurst = 10;
        StartLimitInterval = 900;
      };
      serviceConfig = {
        Type = "notify";
        User = "root";
        Restart = "always";
        RestartSec = 90;
        NotifyAccess = "all";
        TimeoutStartSec = 60;
      };
      script = with pkgs; ''
        set -euo pipefail

        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
        }

        processIpChange() {
          ${concatStringsSep "\n" (map (unit: "${pkgs.systemd}/bin/systemctl restart ${unit}") cfg.dependents)}
        }

        # Setup trap for cleanup
        trap 'log "Service stopping"; exit 0' TERM INT

        IPV6_ADDRESS=
        RETRY_BACKOFF=5

        log "Initializing IP Watcher"
        systemd-notify STATUS="Initializing IP Watcher"

        while true; do
          # Get global unicast IPv6 address (not link-local)
          NEW_IPV6_ADDRESS=$(${iproute2}/sbin/ip -6 addr show dev "${networkDevice}" |
                            ${gnugrep}/bin/grep -v 'scope link' |
                            ${gnugrep}/bin/grep 'scope global' |
                            ${gawk}/bin/awk '{print $2}' |
                            ${uutils-coreutils}/bin/uutils-cut -d/ -f1 |
                            head -n 1)

          if [ -z "$NEW_IPV6_ADDRESS" ]; then
            log "Error: No global IPv6 address found on device ${networkDevice}"
            systemd-notify STATUS="Waiting for IPv6 address..."
            sleep ${toString cfg.pollingPeriod}
            continue
          fi

          if [ "$IPV6_ADDRESS" = "$NEW_IPV6_ADDRESS" ]; then
            sleep ${toString cfg.pollingPeriod}
            continue
          fi

          log "Detected ip change from $IPV6_ADDRESS to $NEW_IPV6_ADDRESS"
          systemd-notify STATUS="Detected ip change from $IPV6_ADDRESS to $NEW_IPV6_ADDRESS"

          if processIpChange; then
            log "Successfully processed ip change"
            IPV6_ADDRESS="$NEW_IPV6_ADDRESS"
            RETRY_BACKOFF=5  # Reset backoff on success
            systemd-notify READY=1 STATUS="Monitoring for updates..."
            systemd-notify BARRIER=1
          else
            RETRY_STATUS=$?
            log "Error: Failed to update Route53 records. Command exited with status $RETRY_STATUS"

            # Implement exponential backoff
            log "Retrying in $RETRY_BACKOFF seconds..."
            systemd-notify STATUS="Failed to handle ip update. Retrying in $RETRY_BACKOFF seconds..."
            systemd-notify BARRIER=1

            sleep $RETRY_BACKOFF

            # Double the backoff time for next failure, up to the maximum
            RETRY_BACKOFF=$((RETRY_BACKOFF * 2))
            if [ $RETRY_BACKOFF -gt ${toString cfg.retryBackoffMax} ]; then
              RETRY_BACKOFF=${toString cfg.retryBackoffMax}
            fi

            continue
          fi

          sleep ${toString cfg.pollingPeriod}
        done
      '';
    };
  };
}
