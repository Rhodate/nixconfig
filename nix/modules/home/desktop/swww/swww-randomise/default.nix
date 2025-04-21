{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.desktop.swww.randomise = {
    enable = mkOption {
      description = "Whether to enable the swww-randomise daemon";
      type = types.bool;
      default = false;
    };
    interval = mkOption {
      description = "The interval at which to rotate the wallpaper";
      type = types.int;
      default = 5;
    };
    wallpaperFolder = mkOption {
      description = "The folder of wallpapers to rotate through";
      type = types.path;
      default = null;
    };
  };

  config = let
    cfg = config.swarm.desktop.swww.randomise;
  in
    mkIf cfg.enable {
      systemd.user.services.swww-randomise-daemon = {
        Unit = {
          Wants = ["hyprland-session.target"];
          After = ["hyprland-session.target"];
          Requires = ["hyprland-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.swarm.swww-randomise}/bin/swww-randomise ${cfg.wallpaperFolder} ${toString cfg.interval}";
          Type = "exec";
          Restart = "always";
          RestartSec = 5;
          StartLimitInterval = 0;
        };
        Install = {
          WantedBy = ["hyprland-session.target"];
        };
      };
    };
}
