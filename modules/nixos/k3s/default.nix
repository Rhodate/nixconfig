{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  options.swarm.k3s = {
    enable = mkEnableOption "Whether to enable k3s";
  };
  config = mkIf config.swarm.k3s.enable {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--debug"
      ];
    };

    fileSystems."/var/lib/rancher/k3s" = {
        device = "/nix/persist/var/lib/rancher/k3s";
        fsType = "none";
        options = [ "bind" ];
    };
  };
}
