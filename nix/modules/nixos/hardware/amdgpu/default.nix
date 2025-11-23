{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.swarm.hardware.amdgpu;
in
{
  options.swarm.hardware.amdgpu = with types; {
    enable = mkOption {
      description = "Enable drivers and patches for AMD hardware.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.rocmSupport = true;
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      # Opencl setup
      graphics.extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
    environment.systemPackages = with pkgs; [
      clinfo
    ];

    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
