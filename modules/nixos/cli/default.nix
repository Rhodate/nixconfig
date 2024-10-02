# cli utilities for managing the nixos system itself. We should always have these
{
  pkgs,
  lib,
  ...
}:
with lib; let
  flakePath = "/home/${swarm.user}/swarm.flake";
in {
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
}
