{
  lib,
  config,
  ...
}:
with lib; {
  sops.age.keyFile = swarm.ophia.keyFile;
  sops.secrets.kubeconfig = {
    sopsFile = snowfall.fs.get-file "secrets/management/kubeconfig.yaml";
    format = "yaml";
    key = ""; # Output the yaml file, instead of trying to extract a specific key
    path = "/home/${swarm.user}/.kube/config";
    owner = config.users.users.${swarm.user}.name;
  };
  sops.secrets.syncthing-cert = {
    sopsFile = snowfall.fs.get-file "secrets/syncthing/cert.pem";
    format = "binary";
    owner = config.users.users.syncthing.name;
  };
  sops.secrets.syncthing-key = {
    sopsFile = snowfall.fs.get-file "secrets/syncthing/key.pem";
    format = "binary";
    owner = config.users.users.syncthing.name;
  };
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
