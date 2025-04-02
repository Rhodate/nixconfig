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
    host=
    debug=
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --debug)
          debug=1
          ;;
        -d)
          debug=1
          ;;
        *)
          if [ -n "$host" ]; then
            echo "Only expected one host to be specified"
            exit 1
          fi
          host=$1
          ;;
      esac
      shift
    done

    buildArgs=
    if [ -n "$debug" ]; then
      buildArgs="--show-trace"
    fi

    if [ "$command" = "deploy" ]; then
      if [ -n "$host" ]; then
        targetIp=$(${pkgs.yq}/bin/yq -r .''${host} $host_config_file)

        system=$(${pkgs.nix}/bin/nix build .\#nixosConfigurations.''${host}.config.system.build.toplevel $buildArgs -L --print-out-paths)
        ${pkgs.nix}/bin/nix-copy-closure --to ${swarm.user}@''${targetIp} $system

        ${pkgs.openssh}/bin/ssh -t ${swarm.user}@''${targetIp} \
          sudo systemd-run \
            -E LOCALE_ARCHIVE \
            -E NIXOS_INSTALL_BOOTLOADER=1 \
            --collect --no-ask-password --pipe --quiet --service-type=exec --unit=swarm-rebuild-switch-to-configuration --wait \
            ''${system}/bin/switch-to-configuration switch
      else
        ${pkgs.nh}/bin/nh os switch -- $buildArgs -j 4
      fi
    fi
  ''
