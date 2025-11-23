{
  config,
  lib,
  ...
}:
with lib;
{
  options.swarm.desktop.hyprland.wofi = {
    enable = mkOption {
      description = "Whether to enable and configure Hyprland";
      type = with types; bool;
      default = true;
    };
  };

  config =
    let
      cfg = config.swarm.desktop.hyprland;
    in
    mkIf (cfg.enable && cfg.wofi.enable) {
      programs.wofi.enable = true;
    };
}
