{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.swarm.fs = with types; {
    type = mkOption {
      type =
        with types;
        nullOr (enum [
          "btrfs"
          "zfs"
        ]);
      default = null;
      description = "Which filesystem to use";
    };
  };

  config =
    let
      cfg = config.swarm.fs;
    in
    mkMerge [
      {
        boot = {
          tmp.cleanOnBoot = true;
          supportedFilesystems = [ "ntfs" ];
        };

        environment.systemPackages = with pkgs; [
          e2fsprogs # ext2 | ext3 | ext4.
          libxfs # SGI XFS.
        ];
      }

      (mkIf (cfg.type == "zfs") {
        boot = {
          supportedFilesystems = [ "zfs" ];
          zfs.forceImportRoot = false;
        };
      })
    ];
}
