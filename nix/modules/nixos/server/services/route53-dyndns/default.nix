{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.swarm.server.services.route53-dyndns;
  networkDevice = config.swarm.hardware.networking.networkDevice;

  # Define the record type
  recordType = types.submodule {
    options = {
      weight = mkOption {
        type = types.int;
        default = 10;
        description = "Weight for the weighted record set.";
      };

      identifier = mkOption {
        type = types.nullOr types.str;
        # Create a default identifier that combines hostname and record prefix (attrset key)
        default = null;
        description = "Unique identifier for this record in the weighted set.";
      };
    };
  };

  # Function to get the domain name from the hosted zone ID
  getDomainFromZoneId =
    zoneId:
    let
      # This would ideally query AWS for the domain name, but for now we'll use the default domain
      domain = swarm.domainName;
    in
    domain;

  # Function to construct the full record name from prefix (attrset key) and domain
  getFullRecordName = prefix: "${prefix}.${getDomainFromZoneId cfg.hostedZoneId}";

  # Combine user-defined records with the default hostname record if enabled
  allRecords =
    let
      defaultRecord = {
        ${config.networking.hostName} = {
          weight = 10;
          identifier = "${config.networking.hostName}-default";
        };
      };

      # Add default identifiers that include the prefix for uniqueness
      addIdentifiers = mapAttrs (
        prefix: record:
        let
          identifierValue =
            if record.identifier == null then "${config.networking.hostName}-${prefix}" else record.identifier;
        in
        record // { identifier = identifierValue; }
      );

      userRecords = addIdentifiers cfg.records;
    in
    if cfg.enableDefaultHostnameRecord && !(cfg.records ? ${config.networking.hostName}) then
      userRecords // defaultRecord
    else
      userRecords;
in
{
  options.swarm.server.services.route53-dyndns = {
    enable = mkEnableOption "Enable Route53 dynamic DNS";

    hostedZoneId = mkOption {
      type = types.str;
      description = "The Route53 hosted zone ID.";
    };

    records = mkOption {
      type = types.attrsOf recordType;
      default = { };
      description = "Attribute set of records to maintain, with weights and identifiers. The attribute name is used as the subdomain prefix.";
      example = literalExpression ''
        {
          service = {  # Will become service.example.com
            weight = 20;
          };
          backup = {   # Will become backup.example.com
            weight = 10;
          };
        }
      '';
    };

    enableDefaultHostnameRecord = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable a default record for {hostname}.{domain}";
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
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostedZoneId != "";
        message = "hostedZoneId is required";
      }
      {
        assertion = cfg.records != { } || cfg.enableDefaultHostnameRecord;
        message = "records must be provided or enableDefaultHostnameRecord must be true";
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

    users = {
      users.route53-dyndns = {
        name = cfg.serviceUserName;
        password = "";
        isSystemUser = true;
        group = "route53-dyndns";
      };
      groups.route53-dyndns = { };
    };
    systemd.timers.route53-dyndns = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnStartupSec = "30s";
        OnUnitActiveSec = "2m";
        Unit = config.systemd.services.route53-dyndns.name;
      };
    };
    systemd.services.route53-dyndns = {
      name = "route53-dyndns.service";
      description = "Maintains Route53 weighted records";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "route53-dyndns";
      };
      script = with pkgs; ''
        set -euo pipefail

        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
        }

        # Setup trap for cleanup
        trap 'log "Service stopping"; exit 0' TERM INT

        export AWS_CONFIG_FILE="${cfg.awsCredentialsFile}"

        # Get global unicast IPv6 address (not link-local)
        NEW_IPV6_ADDRESS=$(${iproute2}/sbin/ip -6 addr show dev "${networkDevice}" |
                          ${gnugrep}/bin/grep -v 'scope link' |
                          ${gnugrep}/bin/grep 'scope global' |
                          ${gawk}/bin/awk '{print $2}' |
                          ${uutils-coreutils}/bin/uutils-cut -d/ -f1 |
                          head -n 1)

        if [ -z "$NEW_IPV6_ADDRESS" ]; then
          log "Error: No global IPv6 address found on device ${networkDevice}"
          exit 1
        fi

        log "Updating Route53 records to $NEW_IPV6_ADDRESS"

        # Create the change batch JSON inline
        CHANGE_BATCH='{
          "Changes": [
            ${concatStringsSep ",\n              " (
              mapAttrsToList (prefix: record: ''
                {
                  "Action": "UPSERT",
                  "ResourceRecordSet": {
                    "Name": "${getFullRecordName prefix}",
                    "Type": "AAAA",
                    "TTL": ${toString cfg.ttl},
                    "SetIdentifier": "${record.identifier}",
                    "Weight": ${toString record.weight},
                    "ResourceRecords": [
                      {
                        "Value": "'"$NEW_IPV6_ADDRESS"'"
                      }
                    ]
                  }
                }
              '') allRecords
            )}
          ]
        }'

        # Update Route53 records
        if ${awscli2}/bin/aws route53 change-resource-record-sets \
            --cli-connect-timeout 15 \
            --cli-read-timeout 15 \
            --hosted-zone-id "${cfg.hostedZoneId}" \
            --change-batch "$CHANGE_BATCH"; then

          log "Successfully updated Route53 records to $NEW_IPV6_ADDRESS"
          exit 0
        else
          STATUS=$?
          log "Error: Failed to update Route53 records. Command exited with status $STATUS"
          exit $STATUS
        fi
      '';
    };
  };
}
