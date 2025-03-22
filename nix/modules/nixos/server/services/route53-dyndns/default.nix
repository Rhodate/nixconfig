{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.swarm.server.services.route53-dyndns;
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

    networkDevice = mkOption {
      type = types.str;
      description = "Name of the network device to get IPv6 address from.";
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
        assertion = cfg.networkDevice != "";
        message = "networkDevice is required";
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
      serviceConfig = {
        Type = "oneshot";
        User = "route53-dyndns";
      };
      script = ''
        export IPV6_ADDRESS=$(${pkgs.iproute2}/sbin/ip -6 addr show dev "${cfg.networkDevice}" | ${pkgs.gnugrep}/bin/grep -m 1 'inet6 ' | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.uutils-coreutils}/bin/uutils-cut -d/ -f1)

        if [ -z "$IPV6_ADDRESS" ]; then
          echo "Error: No IPv6 address found on device ${cfg.networkDevice}"
          exit 1
        fi

        echo "$IPV6_ADDRESS"

        export AWS_CONFIG_FILE="${cfg.awsCredentialsFile}"
        ${pkgs.awscli2}/bin/aws route53 change-resource-record-sets \
          --hosted-zone-id "${cfg.hostedZoneId}" \
          --change-batch '{
            "Changes": [
              {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                  "Name": "${cfg.recordName}",
                  "Type": "AAAA",
                  "TTL": ${builtins.toString cfg.ttl},
                  "ResourceRecords": [
                    {
                      "Value": "'"$IPV6_ADDRESS"'"
                    }
                  ]
                }
              }
            ]
          }'

        echo "Route53 record updated successfully."
      '';
    };
  };
}
