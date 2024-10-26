{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
with lib; {
  # HACK: Here, because importing in flake.nix does not work.
  imports = [inputs.hyprland.homeManagerModules.default];

  options.swarm.desktop.hyprland = {
    enable = mkOption {
      description = "Whether to enable and configure Hyprland";
      type = with types; bool;
      default = false;
    };
  };

  config = let
    cfg = config.swarm.desktop.hyprland;
  in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        inputs.hyprland-contrib.packages.x86_64-linux.grimblast
        playerctl
      ];

      xdg.portal = let
        cfg = config.wayland.windowManager.hyprland;
      in {
        enable = true;
        extraPortals = [inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland];
        configPackages = lib.mkDefault [cfg.finalPackage];
      };

      wayland.windowManager.hyprland = {
        enable = true;

        package = inputs.hyprland.packages.${system}.hyprland;

        plugins = [
        ];
        settings = {
          "$mod" = "SUPER";

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          xwayland = {
            force_zero_scaling = true;
          };

          exec-once = [
            "hyprctl setcursor Bibata-Modern-Ice 22"
          ];

          workspace = [
            "1,monitor:DP-1"
            "2,monitor:DP-2"
            "3,monitor:DP-1"
            "4,monitor:DP-1"
            "5,monitor:DP-1"
          ];

          windowrule = [
            "opacity 0.8 override 0.8 override 0.8 override,^(kitty)$"
            "workspace 3,title:Discord"
            "workspace 5,title:[sS]team"
            "float,[tT]or.*"
          ];

          bind = [
            "ALT, space, exec, wofi --show drun -I"
            "$mod SHIFT, w, killactive"
            "$mod SHIFT, q, exit"
            "$mod, q, exec, kitty"
            "$mod, h, movefocus, l"
            "$mod, j, movefocus, d"
            "$mod, k, movefocus, u"
            "$mod, l, movefocus, r"
            "$mod ALT, h, movewindow, l"
            "$mod ALT, j, movewindow, d"
            "$mod ALT, k, movewindow, u"
            "$mod ALT, l, movewindow, r"
            "$mod CTRL, h, focusmonitor, l"
            "$mod CTRL, j, focusmonitor, d"
            "$mod CTRL, k, focusmonitor, u"
            "$mod CTRL, l, focusmonitor, r"
            "$mod CTRL ALT, h, swapactiveworkspaces, l current"
            "$mod CTRL ALT, j, swapactiveworkspaces, d current"
            "$mod CTRL ALT, k, swapactiveworkspaces, u current"
            "$mod CTRL ALT, l, swapactiveworkspaces, r current"
            "$mod CTRL ALT, h, focusmonitor, l"
            "$mod CTRL ALT, j, focusmonitor, d"
            "$mod CTRL ALT, k, focusmonitor, u"
            "$mod CTRL ALT, l, focusmonitor, r"
            "$mod, t, togglefloating, t"
            "$mod, F, fullscreen, toggle"

            "$mod, mouse:272, movewindow"

            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"

            "$mod ALT, 1, movetoworkspace, 1"
            "$mod ALT, 2, movetoworkspace, 2"
            "$mod ALT, 3, movetoworkspace, 3"
            "$mod ALT, 4, movetoworkspace, 4"
            "$mod ALT, 5, movetoworkspace, 5"
            "$mod ALT, 6, movetoworkspace, 6"
            "$mod ALT, 7, movetoworkspace, 7"
            "$mod ALT, 8, movetoworkspace, 8"
            "$mod ALT, 9, movetoworkspace, 9"
            "$mod ALT, 0, movetoworkspace, 10"

            ", XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -10%"
            ", XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +10%"
            ", XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPlay, exec, playerctl play-pause"

            "CTRL, Print, exec, grimblast copy area"
            "CTRL SHIFT, Print, exec, grimblast save area"
            "ALT CTRL SHIFT, Print, exec, grimblast copy active"
            ", Print, exec, grimblast copy output"
          ];

          input = {
            accel_profile = "flat";
            follow_mouse = 2;
          };

          monitor = [
            "DP-1, highrr, 0x0, 1"
            "DP-2, 2560x1440, -2560x0, 1"
            "Unknown-1,disable"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 5;
            border_size = 2;
            layout = "dwindle";
            resize_on_border = true;
          };

          dwindle = {
            pseudotile = true;
          };

          decoration = {
            rounding = 0;
            blur = {
              enabled = true;
              size = 3;
              passes = 2;
              new_optimizations = true;
              ignore_opacity = true;
            };
          };

          animations = {
            enabled = true;
            bezier = [
              "overshot,0.05,0.9,0.1,1.1"
              "overshot,0.13,0.99,0.29,1."
            ];
            animation = [
              "windows,1,7,overshot,slide"
              "border,1,10,default"
              "fade,1,10,default"
              "workspaces,1,7,overshot,slidevert"
            ];
          };
        };
      };
    };
}
