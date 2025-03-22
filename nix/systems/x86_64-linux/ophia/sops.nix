{
  lib,
  config,
  ...
}:
with lib; let
  keyFile = "/nix/secrets/sops/age/keys.txt";
in {
  sops.age.keyFile = keyFile;
  sops.secrets.kubeconfig = {
    sopsFile = snowfall.fs.get-file "secrets/management/kubeconfig.yaml";
    format = "yaml";
    key = ""; # Output the yaml file, instead of trying to extract a specific key
    path = "/home/${swarm.user}/.kube/config";
    owner = config.users.users.${swarm.user}.name;
  };
}
