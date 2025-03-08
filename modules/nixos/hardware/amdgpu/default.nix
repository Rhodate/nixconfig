{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.swarm.hardware.amdgpu;
in {
  options.swarm.hardware.amdgpu = with types; {
    enable = mkOption {
      description = "Enable drivers and patches for AMD hardware.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      amdgpu.amdvlk = {
        enable = true;
        support32Bit.enable = true;
      };
    };

    services.xserver.videoDrivers = ["amdgpu"];
  };
}
