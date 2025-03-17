{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.swarm.hardware.nvidia;
in {
  options.swarm.hardware.nvidia = with types; {
    enable = mkOption {
      description = "Enable drivers and patches for Nvidia hardware.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.cudaSupport = true;
    hardware = {
      graphics.enable = true;
      nvidia-container-toolkit.enable = true;
      nvidia = {
        modesetting.enable = true;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        nvidiaSettings = true;
      };
    };

    environment = {
      variables = {
        CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      };
      shellAliases = {nvidia-settings = "nvidia-settings --config='$XDG_CONFIG_HOME'/nvidia/settings";};
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        WLR_DRM_NO_ATOMIC = "1";
        NIXOS_OZONE_WL = 1;
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
