{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.swarm.server.services.route53-dyndns;
  networkDevice = config.swarm.hardware.networking.networkDevice;
in {
  options.swarm.server.services.route53-dyndns = {
    enable = mkEnableOption "Enable Route53 dynamic DNS";

    hostedZoneId = mkOption {
      type = types.str;
      description = "The Route53 hosted zone ID.";
    };

    recordName = mkOption {
      type = types.str;
      description = "The record name (e.g., 'home.example.com').";
    };

    awsCredentialsFile = mkOption {
      type = types.path;
      description = "Path to the AWS credentials file (sops-nix output).";
    };

    serviceUserName = mkOption {
      type = types.str;
      default = "route53-dyndns";
      description = "User name for the service.";
    };

    ttl = mkOption {
      type = types.int;
      default = 300;
      description = "TTL for the record.";
    };

    pollingPeriod = mkOption {
      type = types.int;
      default = 5;
      description = "Polling period in seconds.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostedZoneId != "";
        message = "hostedZoneId is required";
      }
      {
        assertion = cfg.recordName != "";
        message = "recordName is required";
      }
      {
        assertion = cfg.awsCredentialsFile != "";
        message = "awsCredentialsFile is required";
      }
      {
        assertion = cfg.serviceUserName != "";
        message = "serviceUserName is required";
      }
    ];

    # set up user for service, it should be configured as a generic systemd user
    users = {
      users.route53-dyndns = {
        name = cfg.serviceUserName;
        password = "";
        isSystemUser = true;
        group = "route53-dyndns";
      };
      groups.route53-dyndns = {};
    };

    systemd.services.route53-dyndns = {
      name = "route53-dyndns.service";
      description = "Maintains a Route53 record";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      unitConfig = {
        StartLimitBurst = 10;
        StartLimitIntervalSec = 900;
      };
      serviceConfig = {
        Type = "notify";
        User = "route53-dyndns";
        Restart = "always";
        RestartSec = 90;
        NotifyAccess = "all";
        TimeoutStartSec = 60;
      };
      script = with pkgs; ''
        IPV6_ADDRESS=
        systemd-notify STATUS="Initializing Route53 dynamic DNS"
        export AWS_CONFIG_FILE="${cfg.awsCredentialsFile}"
        while : ; do
          NEW_IPV6_ADDRESS=$(${iproute2}/sbin/ip -6 addr show dev "${networkDevice}" | ${gnugrep}/bin/grep -m 1 'inet6 ' | ${gawk}/bin/awk '{print $2}' | ${uutils-coreutils}/bin/uutils-cut -d/ -f1)

          if [ -z "$NEW_IPV6_ADDRESS" ]; then
            echo "Error: No IPv6 address found on device ${networkDevice}"
            exit 1
          fi

          if [ "$IPV6_ADDRESS" = "$NEW_IPV6_ADDRESS" ]; then
            sleep ${toString cfg.pollingPeriod}
            continue
          fi

          systemd-notify STATUS="Updating Route53 record from $IPV6_ADDRESS to $NEW_IPV6_ADDRESS"

          ${awscli2}/bin/aws route53 change-resource-record-sets \
              --cli-connect-timeout 15 \
              --cli-read-timeout 15 \
              --hosted-zone-id "${cfg.hostedZoneId}" \
              --change-batch '{
                "Changes": [
                  {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                      "Name": "${cfg.recordName}",
                      "Type": "AAAA",
                      "TTL": ${toString cfg.ttl},
                      "ResourceRecords": [
                        {
                          "Value": "'"$NEW_IPV6_ADDRESS"'"
                        }
                      ]
                    }
                  }
                ]
              }'


          if [ $? -ne 0 ]; then
            echo "Error: Failed to update Route53 record. Command exited with status $?"
            systemd-notify --status="Failed to update Route53 record. Retrying in 5 seconds..."
            systemd-notify BARRIER=1
          else
            echo "Updated Route53 record from $IPV6_ADDRESS to $NEW_IPV6_ADDRESS"
            IPV6_ADDRESS="$NEW_IPV6_ADDRESS"
            systemd-notify READY=1 STATUS="Monitoring for updates..."
            systemd-notify BARRIER=1
          fi

          sleep ${toString cfg.pollingPeriod}
        done
      '';
    };
  };
}
