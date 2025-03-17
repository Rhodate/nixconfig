{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.cli.btop = {
    enable = mkOption {
      description = "Enable btop cli util";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.btop.enable {
    home.file."btop/themes/catppuccin_mocha.theme".source = ./catppuccin_mocha.theme;

    programs.btop = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
        theme_background = false;
        vim_keys = true;
        update_ms = 2000;
        proc_tree = true;
      };
    };
  };
}
