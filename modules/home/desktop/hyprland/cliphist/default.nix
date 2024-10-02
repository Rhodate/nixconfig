{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.desktop.hyprland.cliphist = {
    enable = mkOption {
      description = "Whether to enable and configure Hyprland";
      type = with types; bool;
      default = true;
    };
  };

  config = let
    cfg = config.swarm.desktop.hyprland;
  in
    mkIf (cfg.enable
      && cfg.cliphist.enable) {
      services.cliphist.enable = true;
    };
}
