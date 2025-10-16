{
  lib,
  config,
  ...
}:
with lib; {
  sops.age.keyFile = "/nix/secrets/sops/age/keys.txt";
  sops.secrets.route53-dyndns-credentials = mkIf config.swarm.server.services.route53-dyndns.enable {
    format = "ini";
    sopsFile = snowfall.fs.get-file "secrets/server/aws/dyndns.ini";
    owner = config.swarm.server.services.route53-dyndns.serviceUserName;
  };
  sops.secrets.syncthing-cert = mkIf config.swarm.syncthing.enable {
    sopsFile = snowfall.fs.get-file "secrets/syncthing/cert.pem";
    format = "binary";
    owner = config.users.users.syncthing.name;
  };
  sops.secrets.syncthing-key = mkIf config.swarm.syncthing.enable {
    sopsFile = snowfall.fs.get-file "secrets/syncthing/key.pem";
    format = "binary";
    owner = config.users.users.syncthing.name;
  };
}
