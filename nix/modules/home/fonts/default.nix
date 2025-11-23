{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.swarm.fonts;
in
{
  options.swarm.fonts = {
    enable = mkOption {
      description = "Install and configure fonts for gui";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "FiraMono Nerd Font" ];
          sansSerif = [ "FiraCode Nerd Font" ];
        };
      };
    };
  };
}
