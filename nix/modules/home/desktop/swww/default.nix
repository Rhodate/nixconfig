{
  config,
  lib,
  inputs,
  system,
  pkgs,
  ...
}:
with lib; {
  options.swarm.desktop.swww = {
    enable = mkOption {
      description = "Whether to enable swww for wayland wallpapers";
      type = types.bool;
      default = false;
    };
    defaultWallpaper = mkOption {
      description = "The default image to show as the wallpaper (see swww docs for formats)";
      type = types.path;
      default = null;
    };
  };

  config = let
    cfg = config.swarm.desktop.swww;
  in
    mkIf cfg.enable (mkMerge [
      {
        home.packages = with inputs; [
          swww.packages.${system}.swww
        ];
      }

      (mkIf config.swarm.desktop.hyprland.enable
        {
          wayland.windowManager.hyprland = {
            settings = {
              exec-once = [
                "${pkgs.uwsm}/bin/uwsm-app -- ${inputs.swww.packages.${system}.swww}/bin/swww-daemon"
                (mkIf (cfg.defaultWallpaper != "") "${inputs.swww.packages.${system}.swww}/bin/swww img --transition-type none --transition-step 2 --transition-fps 144 --transition-duration 0 ${cfg.defaultWallpaper}")
              ];
            };
          };
        })
    ]);
}
