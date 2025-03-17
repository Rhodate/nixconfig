{
  lib,
  config,
  ...
}:
with lib; {
  options.swarm.hardware.input-remapper = {
    enable = mkEnableOption "Whether to enable input remapper";
  };
  config = mkIf config.swarm.hardware.input-remapper.enable {
    services.input-remapper = {
      enable = true;
    };
  };
}
