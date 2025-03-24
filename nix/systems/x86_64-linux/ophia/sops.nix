{
  lib,
  config,
  ...
}:
with lib; let
  keyFile = "/nix/secrets/sops/age/keys.txt";
in {
  sops.age.keyFile = keyFile;
  # Make sure the user shell is aware of the sops key
  home-manager.users.${swarm.user}.swarm.cli.sopsAgeKeyFile = keyFile;
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
}
