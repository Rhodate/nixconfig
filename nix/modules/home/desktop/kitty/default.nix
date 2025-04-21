{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.desktop.kitty = {
    enable = mkOption {
      description = "Whether to enable and configure kitty terminal";
      type = with types; bool;
      default = false;
    };
  };

  config = let
    cfg = config.swarm.desktop.kitty;
  in
    mkIf cfg.enable {
      home.file.".config/kitty/tab_bar.py" = {
        source = ./res/tab_bar.py;
      };

      home.file.".config/kitty/ssh.conf" = {
        source = ./res/ssh.conf;
      };

      # TODO(rhoddy): Move this into its own module. Maybe as part of nix'ing vim
      # This and the pass_keys script below are part of nvim kitty navigator
      # Along with the keybindings for moving between kitty windows pointing at this script
      home.file.".config/kitty/navigate_kitty.py" = {
        source = ./res/navigate_kitty.py;
      };

      home.file.".config/kitty/pass_keys.py" = {
        source = ./res/pass_keys.py;
      };

      programs.kitty = {
        enable = true;
        keybindings = {
          "alt+s" = "launch --cwd=current";
          "alt+v" = "launch --cwd=current --location=vsplit";
          "alt+r" = "layout_action rotate";
          "alt+k" = "move_window up";
          "alt+h" = "move_window left";
          "alt+l" = "move_window right";
          "alt+j" = "move_window down";
          "ctrl+h" = "kitten pass_keys.py neighboring_window left ctrl+h";
          "ctrl+j" = "kitten pass_keys.py neighboring_window bottom ctrl+j";
          "ctrl+k" = "kitten pass_keys.py neighboring_window top ctrl+k";
          "ctrl+l" = "kitten pass_keys.py neighboring_window right ctrl+l";
          "ctrl+shift+s" = "show_scrollback";
          "alt+shift+f" = "toggle_fullscreen";
          "alt+left" = "send_text all \x1bb";
          "alt+right" = "send_text all \x1bf";
          "ctrl+shift+]" = "next_tab";
          "ctrl+shift+[" = "previous_tab";
        };
        settings = {
          enabled_layouts = "splits:split_axis=vertical";

          allow_remote_control = "yes";
          listen_on = "unix:/tmp/mykitty";

          editor = "nvim";

          font_family = "Fira Code";
          font_size = 11;
          disable_ligatures = "cursor";
          symbol_map = ''
            U+E5FA-U+E62B,U+E700-U+E7C5,U+F000-U+F2E0,U+E200-U+E2A9,U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+f500-U+fd46 Symbols Nerd Font
            symbol_map U+E0A1-U+E0A3,U+E0C0-U+E0C7 PowerlineSymbols''; # Does this hack work? We'll see... :3

          scrollback_lines = 10000000;

          hide_window_decorations = true;
          wayland_titlebar_color = "system";

          window_margin_width = 2;

          placement_strategy = "top-left";

          tab_bar_edge = "top";
          tab_bar_margin_width = 0;
          tab_bar_min_tabs = 1;
          tab_switch_strategy = "left";
          tab_bar_style = "custom";
          tab_powerline_style = "angled";

          macos_option_as_alt = true;
          macos_quit_when_last_window_closed = true;
          update_check_interval = 0;
        };
        themeFile = "Catppuccin-Mocha";
      };
    };
}
