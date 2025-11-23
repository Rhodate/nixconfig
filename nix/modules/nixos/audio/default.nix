{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.swarm.audio;
in
{
  options.swarm.audio = with types; {
    enable = mkOption {
      description = "Enable pipewire";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
    programs.noisetorch.enable = true;

    environment.systemPackages = with pkgs; [ pavucontrol ];
  };
}
