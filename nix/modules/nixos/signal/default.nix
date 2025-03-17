{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.signal = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable signal messaging";
    };
  };

  config = let
    cfg = config.swarm.signal;
  in
    mkIf cfg.enable {
      services.signald = {
        enable = true;
        user = swarm.user;
      };

      environment.systemPackages = [pkgs.signaldctl];
    };
}
