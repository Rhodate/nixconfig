{
  writeShellScriptBin,
  lib,
  pkgs,
  ...
}:
with lib;
writeShellScriptBin "sw" ''
    #!/usr/bin/env zsh
    set -euo pipefail

    if [ $# -lt 1 ]; then
      echo "Usage: sw <command> <args...>"
      exit 1
    fi

    host_config_file=/etc/sw/swarm-hosts.yaml
    if [ ! -f $host_config_file ]; then
      echo "Config file $host_config_file does not exist"
      exit 1
    fi

    command=$1
    shift
    if [ "$command" = "deploy" ]; then
      if [ "$#" -gt 0 ]; then
        targetHost=$1
        shift

        targetIp=$(${pkgs.yq}/bin/yq -r .''${targetHost} $host_config_file)

        system=$(${pkgs.nix}/bin/nix build .\#nixosConfigurations.''${targetHost}.config.system.build.toplevel -L --print-out-paths $@)

        ${pkgs.nix}/bin/nix-copy-closure --to ${swarm.user}@''${targetHost} $system

        ${pkgs.openssh}/bin/ssh -t ${swarm.user}@''${targetIp} sudo ''${system}/bin/switch-to-configuration switch
      else
        ${pkgs.nh}/bin/nh os switch -- -j 8
      fi
    fi

    
  ''
