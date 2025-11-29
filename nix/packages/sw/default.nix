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
      FLAKE=''${FLAKE:-.}

      if [ $# -lt 1 ]; then
        echo "Usage: $0 <command> [options] [host]

  COMMANDS
    deploy
      Initiates a NixOS configuration deployment.
      - If a `host` is specified, the script attempts a remote
        deployment to that host.
      - If no `host` is specified, the script performs a local
        rebuild and switch using `nixos-rebuild switch`.

  OPTIONS
    -d, --debug
      Enables debug output for underlying Nix commands, typically by
      adding the '--show-trace' flag to build operations.

    -c, --cores <n>
      Specifies the number of CPU cores to utilize for Nix build
      operations. The application of this option depends on the
      specific deployment path (local or remote).

    -b, --boot
      Deploys the config to be applied only on next boot, for breaking changes.

  "
        exit 1
      fi

      command=$1
      shift
      host=
      debug=
      cores=4
      boot=
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --debug)
            debug=1
            ;;
          -d)
            debug=1
            ;;
          -c)
            cores=$2
            shift
            ;;
          --cores)
            cores=$2
            shift
            ;;
          -b)
            boot=1
            ;;
          --boot)
            boot=1
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

      verb=switch
      if [ -n "$boot" ]; then
        verb=boot
      fi

      if [ "$command" = "deploy" ]; then
        if [ -n "$host" ]; then
          system=$(${pkgs.nix-output-monitor}/bin/nom build $FLAKE\#nixosConfigurations.''${host}.config.system.build.toplevel $buildArgs --print-out-paths -j $cores --no-link --print-out-paths)
          if [ "$?" -ne 0 ]; then
            echo "Build failed"
            exit 1
          fi
          echo "Copying closure to ''${host}"
          ${pkgs.nix}/bin/nix-copy-closure --to ${swarm.user}@''${host} --use-substitutes $system

          echo "SSHing to ''${host} and switching to new configuration"
          ${pkgs.openssh}/bin/ssh -t ${swarm.user}@''${host} "
            # Register the new system profile
            sudo nix-env -p /nix/var/nix/profiles/system --set $system

            # Switch to the new configuration
            sudo NIXOS_INSTALL_BOOTLOADER=1 $system/bin/switch-to-configuration $verb

            # Verify the profile was updated
            echo 'New system profile:'
            sudo readlink -f /nix/var/nix/profiles/system

            echo 'System generations:'
            sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 3

            if [ -d /boot/loader/entries ]; then
              echo 'Boot entries (systemd-boot):'
              sudo ls -la /boot/loader/entries/
            elif [ -f /boot/grub/grub.cfg ]; then
              echo 'GRUB configuration exists'
              sudo grep 'menuentry' /boot/grub/grub.cfg | head -n 5
            fi
          "
        else
          # Build only the current host
          host=$(hostname)
          # Do it separately from switching, so that I can see the changes before typing my password.
          ${pkgs.nix-output-monitor}/bin/nom build $FLAKE\#nixosConfigurations.''${host}.config.system.build.toplevel $buildArgs --print-out-paths -j $cores
          sudo nixos-rebuild $verb --no-reexec --flake $FLAKE\#''${host} -L --cores $cores --show-trace
        fi
      fi
''
