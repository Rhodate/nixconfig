{
  lib,
  config,
  ...
}:
with lib;
{
  sops.secrets.route53-dyndns-credentials = {
    format = "ini";
    sopsFile = snowfall.fs.get-file "secrets/server/aws/dyndns.ini";
    owner = config.swarm.server.services.route53-dyndns.serviceUserName;
  };
  sops.secrets.route53-acme-credentials = {
    format = "ini";
    sopsFile = snowfall.fs.get-file "secrets/server/aws/dyndns.ini";
    owner = "acme";
  };
}
