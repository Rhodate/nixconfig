{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  flakePath = "/home/${swarm.user}/swarm.flake";
in {
  options.swarm.management = {
    enable = mkEnableOption "Whether to enable nixos management utilities";
  };

  config = let
    cfg = config.swarm.management;
  in
    mkIf cfg.enable {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 25";
        flake = flakePath;
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
      ];

      environment.variables = {
        FLAKE = flakePath;
      };
    };
}
