{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.swarm.ai.ollama;
  hardwareCfg = config.swarm.hardware;
in {
  options.swarm.ai.ollama = with types; {
    enable = mkOption {
      description = "Enable ollama";
      type = types.bool;
      default = false;
    };

    rocmOverrideGfx = mkOption {
      description = "Override gfx for rocm";
      type = types.str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      rocmOverrideGfx = cfg.rocmOverrideGfx;
    };
  };
}
