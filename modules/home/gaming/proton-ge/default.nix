{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.swarm.gaming.proton-ge;
in {
  options.swarm.gaming.proton-ge = {
    enable = mkOption {
      description = "Install and configure proton-ge";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
      # Hyprland specific config. If any other window managers get added, they'll need special cases too.
      # Maybe can automate this if more are necessary.
      wayland.windowManager.hyprland.settings.env = [
        "STEAM_EXTRA_COMPAT_TOOLS_PATHS,${pkgs.swarm.proton-ge-custom}"
      ];
  };
}
