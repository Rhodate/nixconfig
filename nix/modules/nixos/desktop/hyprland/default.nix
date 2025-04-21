{lib, ...}:
with lib; {
  options = {
    swarm.desktop.hyprland = {
      enable = mkOption {
        description = "Whether to enable Hyprland";
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
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
    };
    programs.hyprlock.enable = true;
  };
}
