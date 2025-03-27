{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.swarm.server.acme;
in {
  options.swarm.server.acme = {
    enable = mkEnableOption "Enable ACME for Let's Encrypt";
    awsCredentialsFile = mkOption {
      type = types.path;
      description = "Path to the AWS credentials file (sops-nix output).";
    };
    hostedZoneId = mkOption {
      type = types.str;
      description = "The Route53 hosted zone ID.";
    };
    awsRegion = mkOption {
      type = types.str;
      default = "us-east-1";
      description = "The AWS region.";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "benxandercode@gmail.com";
      certs."rhodate.com" = {
        domain = "*.rhodate.com";
        dnsProvider = "route53";
        environmentFile = "${
          pkgs.writeText "aws-creds" ''
            AWS_SDK_LOAD_CONFIG=1
            AWS_CONFIG_FILE=${cfg.awsCredentialsFile}
            AWS_HOSTED_ZONE_ID=${cfg.hostedZoneId}
            AWS_REGION=${cfg.awsRegion}
          ''
        }";
      };
    };

    fileSystems."/var/lib/acme" = {
      device = "/nix/persist/var/lib/acme";
      fsType = "none";
      options = ["bind"];
    };
  };
}
