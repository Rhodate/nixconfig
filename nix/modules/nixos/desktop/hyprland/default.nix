{ lib, config, ... }:
with lib;
{
  options = {
    swarm.desktop.hyprland = {
      enable = mkOption {
        description = "Whether to enable Hyprland";
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf config.swarm.desktop.hyprland.enable {
    programs.uwsm.enable = true;

    programs.uwsm.waylandCompositors = {
      hyprland = {
        binPath = "/run/current-system/sw/bin/Hyprland";
        prettyName = mkForce "(˶˃ ᵕ ˂˶) .ᐟ.ᐟHyprland(˶˃ ᵕ ˂˶) .ᐟ.ᐟ";
      };
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    programs.hyprlock.enable = true;
  };
}
