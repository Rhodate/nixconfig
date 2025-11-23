{
  lib,
  config,
  ...
}:
with lib;
{
  options.swarm.server.k3s = {
    ipsConfigFile = mkOption {
      type = types.str;
      default = "/etc/rancher/k3s/ips.env";
      description = "k3s IPs environment file path";
    };
    externalIp = mkOption {
      type = types.str;
      default = "";
      description = "k3s external IP";
    };
  };
  config = mkIf (config.swarm.server.k3s.enable && (elem "amazon" config.system.nixos.tags)) {
    services.k3s.extraFlags = lib.mkAfter [
      "--node-taint node-role=ingress:NoSchedule"
      "--node-label node-role=ingress"
      "--node-label svccontroller.k3s.cattle.io/enablelb=true"
      (mkIf (
        config.swarm.server.k3s.externalIp != ""
      ) "--node-external-ip=${config.swarm.server.k3s.externalIp}")
      #"--node-external-ip=$IPV6_EXTERNAL_IP"
    ];

    networking.firewall.interfaces.${config.swarm.hardware.networking.networkDevice}.allowedTCPPorts = [
      443
    ];

    #systemd.services.k3s.serviceConfig.EnvironmentFile = mkForce "${config.swarm.server.k3s.ipsConfigFile}";
    #
    #systemd.services.get-public-ips = {
    #  name = "get-public-ips.service";
    #  description = "Get public IPs for k3s";
    #  after = ["network-online.target"];
    #  wants = ["network-online.target"];
    #  wantedBy = [ "k3s.service" ];
    #  serviceConfig = {
    #    Type = "oneshot";
    #    Restart = "on-failure";
    #    RestartSec = 5;
    #    RestartMaxDelaySec=30;
    #    RestartSteps=10;
    #  };
    #  script = ''
    #    set -euo pipefail
    #    token=$(${pkgs.curl}/bin/curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    #    IPV6_EXTERNAL_IP=$(${pkgs.curl}/bin/curl -H "X-aws-ec2-metadata-token: $token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/meta-data/ipv6)
    #    echo "IPV6_EXTERNAL_IP=$IPV6_EXTERNAL_IP" > ${config.swarm.server.k3s.ipsConfigFile}
    #  '';
    #};
  };
}
