{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.swarm.desktop.mpvpaper = {
    enable = mkOption {
      description = "Whether to enable mpvpaper for wayland wallpapers";
      type = types.bool;
      default = false;
    };
    wallpaper = mkOption {
      description = "The mpv video to show as the default wallpaper";
      type = types.path;
      default = null;
    };
  };

  config =
    let
      cfg = config.swarm.desktop.mpvpaper;
    in
    mkIf cfg.enable (mkMerge [
      {
        home.packages = with pkgs; [
          mpvpaper
        ];
      }

      (mkIf config.swarm.desktop.hyprland.enable {
        wayland.windowManager.hyprland = {
          settings = {
            exec-once = [
              ''mpvpaper -o "input-ipc-server=/tmp/mpv-socket" "*" ${cfg.wallpaper}''
            ];
          };
        };
      })
    ]);
}
