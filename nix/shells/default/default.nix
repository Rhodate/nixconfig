{
  lib,
  pkgs,
  mkShell,
  ...
}:
with lib;
  mkShell {
    shellHook = ''
      export SOPS_AGE_KEY_FILE=${swarm.ophia.keyFile};
    '';
    packages = with pkgs; [
      sops
    ];
  }
