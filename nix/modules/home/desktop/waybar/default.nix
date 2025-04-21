{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.desktop.waybar = {
    enable = mkOption {
      description = "Whether to enable and configure waybar";
      type = with types; bool;
      default = false;
    };
  };

  config = let
    cfg = config.swarm.desktop.waybar;
  in
    mkIf cfg.enable {
      home.packages = [pkgs.inter];

      services.playerctld.enable = true;

      # Set up waybar to start when hyprland starts (would be easy to make this support other desktop environments and themes
      wayland.windowManager.hyprland.settings.exec-once = ["${pkgs.uwsm}/bin/uwsm app -- ${pkgs.waybar}/bin/waybar"];

      programs.waybar = {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];});
        settings = {
          mainBar = {
            margin = "5";
            borderRadius = 10;
            layer = "bottom";
            modules-left = ["custom/nix" "hyprland/workspaces" "mpris"];
            modules-center = ["wlr/taskbar"];
            modules-right = ["custom/task-context" "network" "network#speed" "memory" "cpu" "temperature" "clock" "custom/notification" "tray"];

            persistent_workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };

            "hyprland/workspaces" = {
              format = "{icon}";
              on-click = "activate";
              sort-by-number = true;
              format-icons = {
                "1" = " ";
                "2" = "󰈹 ";
                "3" = " ";
                "4" = "󰴸 ";
                "5" = " ";
              };
            };

            mpris = {
              format = "{status_icon}<span weight='bold'>{artist}</span> | {title}";
              status-icons = {
                playing = "󰎈 ";
                paused = "󰏤 ";
                stopped = "󰓛 ";
              };
            };

            "custom/nix" = {
              format = "󱄅 ";
            };

            "wlr/taskbar" = {
              on-click = "activate";
            };

            "custom/task-context" = {
              exec = "~/.config/waybar/scripts/task-context.sh";
              tooltip = false;
              on-click = "task @ none";
              restart-interval = 1;
            };

            "network#interface" = {
              format-ethernet = "󰣶  {ifname}";
              format-wifi = "󰖩 {ifname}";
              tooltip = true;
              tooltip-format = "{ipaddr}";
            };

            "network#speed" = {
              format = "⇡{bandwidthUpBits} ⇣{bandwidthDownBits}";
            };

            cpu = {
              format = "  {usage}% 󰥛 {avg_frequency}";
            };

            memory = {
              format = "  {used:0.1f}G/{total:0.1f}G";
            };

            temperature = {
              format = "{icon} {temperatureC} °C";
              format-icons = ["" "" "" "󰈸"];
            };

            clock = {
              format = "   {:%H:%M}";
              format-alt = "󰃭  {:%Y-%m-%d}";
            };

            "custom/notification" = {
              exec = "~/.config/waybar/scripts/dunst.sh";
              tooltip = false;
              on-click = "dunstctl set-paused toggle";
              restart-interval = 1;
            };

            tray = {
              icon-size = 16;
              spacing = 8;
            };
          };
        };

        style = ''
          * {
            min-height: 0;
          }

          window#waybar {
            font-family: 'Inter', 'FiraCode Nerd Font';
            font-size: 12px;
          }

          tooltip {
          }

          #custom-nix {
            padding: 2px 6px;
          }

          #workspaces button {
            padding: 2px 6px;
            margin: 0 6px 0 0;
          }

          .modules-right * {
            padding: 0 6px;
            margin: 0 0 0 4px;
          }

          #mpris {
            padding: 0 6px;
          }

          #custom-notification {
            padding: 0 6px 0 6px;
          }

          #tray {
            padding: 0 6px;
          }

          #tray * {
            padding: 0;
            margin: 0;
          }
        '';
      };

      xdg.configFile."waybar/scripts/dunst.sh" = {
        text = ''
          COUNT=$(dunstctl count waiting)
          ENABLED="󰂚 "
          DISABLED="󰂛 "
          if [ $COUNT != 0 ]; then DISABLED="󱅫 "; fi
          if dunstctl is-paused | grep -q "false"; then
            echo $ENABLED
          else
            echo $DISABLED
          fi
        '';
        executable = true;
      };

      xdg.configFile."waybar/scripts/task-context.sh" = {
        text = ''
          ICON=" "
          CONTEXT=$(task _get rc.context)

          if [ -z "$CONTEXT" ]; then
            CONTEXT="NONE"
          fi
          echo "$ICON  $CONTEXT"
        '';
        executable = true;
      };
    };
}
