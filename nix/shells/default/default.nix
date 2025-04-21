{
  lib,
  pkgs,
  mkShell,
  ...
}:
with lib;
  mkShell {
    packages = with pkgs; [
      sops
      opentofu
      swarm.swww-randomise
    ];
  }
