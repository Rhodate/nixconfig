{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cnpgOperatorManifest = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml";
    sha256 = "sha256-7OFBgB/vZQdFGjAyse2inp+hWUS3QfpzAXAceBFgzkE=";
  };
in {
  config = mkIf config.swarm.server.k3s.enable {
    system.activationScripts.linkCNPGOperatorAddon = {
      text = ''
        mkdir -p /var/lib/rancher/k3s/server/manifests
        ln -sf ${cnpgOperatorManifest} /var/lib/rancher/k3s/server/manifests/cnpg-operator.yaml
      '';
      deps = ["users" "groups"];
    };
  };
}
