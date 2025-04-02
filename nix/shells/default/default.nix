{
  lib,
  pkgs,
  mkShell,
  ...
}:
with lib;
  mkShell {
    shellHook = ''
      export SOPS_AGE_KEY_FILE=${toString swarm.ophia.keyFile}
    '';
    
    packages = with pkgs; [
      sops
      opentofu
      k9s
      helm
    ];
  }
