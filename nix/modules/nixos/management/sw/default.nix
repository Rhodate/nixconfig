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
  };

  config =
    let
      cfg = config.swarm.management.sw;
    in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        swarm.sw
      ];
    };
}
