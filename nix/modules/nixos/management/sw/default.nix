{
  pkgs,
  lib,
  config,
  ...
}:
with lib; 
{
  options.swarm.management.sw = {
    enable = mkEnableOption "Whether to enable sw cli management tool";
    keyFile = mkOption {
      type = types.str;
      default = "/home/${swarm.user}/.config/sops/age/keys.txt";
      description = "Path to the age key file";
    };
  };

  config = let
    cfg = config.swarm.management.sw;
  in
    mkIf cfg.enable {
      sops.age.keyFile = cfg.keyFile;

      sops.secrets.swarm-hosts = {
        format = "yaml";
        sopsFile = lib.snowfall.fs.get-file "secrets/management/swarm-hosts.yaml";
        path = "/etc/sw/swarm-hosts.yaml"; # This is where the script expects to find the file. %r is the xdg runtime directory
        key = ""; # Output the yaml file, instead of trying to extract a specific key
        owner = config.users.users.${swarm.user}.name;
      };

      environment.systemPackages = with pkgs; [
        swarm.sw
      ];
    };
}
