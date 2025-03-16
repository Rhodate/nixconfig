{
  pkgs,
  lib,
  config,
  ...
}:
with lib; 
{
  options.swarm.cli.sw= {
    enable = mkEnableOption "Whether to enable sw cli management tool";
    keyFile = mkOption {
      type = types.path;
      default = "/home/${config.snowfallorg.user.name}/.config/sops/age/keys.txt";
    };
  };

  config = let
    cfg = config.swarm.cli.sw;
  in
    mkIf (cfg.enable) {
      sops.age.keyFile = cfg.keyFile;

      sops.secrets.swarm-hosts = {
        format = "yaml";
        sopsFile = lib.swarm.secrets-path + /management/swarm-hosts.yaml;
        path = "%r/sw/swarm-hosts.yaml"; # This is where the script expects to find the file. %r is the xdg runtime directory
        key = ""; # Output the yaml file, instead of trying to extract a specific key
      };

      home.packages = with pkgs; [
        swarm.sw
      ];
    };
}
