{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.gaming.steam = {
    enable = mkOption {
      description = "Whether to enable steam";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.gaming.steam.enable {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      mangohud
      swarm.gamescope-launcher
    ];
  };
}
