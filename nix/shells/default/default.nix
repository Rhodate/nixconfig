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

    shellHook = ''
      export SOPS_AGE_KEY_FILE="/nix/secrets/sops/age/keys.txt";
    '';
  }
