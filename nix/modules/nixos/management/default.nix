{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  options.swarm.management = {
    enable = mkEnableOption "Whether to enable nixos management utilities";
    flakePath = mkOption {
      type = types.path;
      description = "Path to the nixos flake";
      default = lib.swarm.flakePath;
    };
  };

  config = let
    cfg = config.swarm.management;
  in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        nix-output-monitor
        swarm.sw
      ];

      environment.variables = {
        FLAKE = cfg.flakePath;
      };
    };
}
