{
  lib,
  config,
  ...
}:
with lib;
{
  options.swarm.syncthing = {
    enable = mkEnableOption "Enable syncthing";
    keyFile = mkOption {
      type = types.path;
      description = "Path to the syncthing key file (sops-nix output).";
    };
    certFile = mkOption {
      type = types.path;
      description = "Path to the syncthing cert file (sops-nix output).";
    };
  };

  config = mkIf config.swarm.syncthing.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      key = config.swarm.syncthing.keyFile;
      cert = config.swarm.syncthing.certFile;
      user = "syncthing";
      group = "syncthing";
      settings = {
        devices = {
          "galazy-s23-ultra" = {
            id = "ELKEX3W-EUIIOUM-QONMXGQ-EMMTNE7-HNVFSG2-EIUQHU5-QJ7GWGB-U4PVTQB";
          };
        };
        folders = {
          "Images" = {
            path = "/home/rhoddy/Images";
            id = "tfxqa-ug4ve";
            devices = [ "galazy-s23-ultra" ];
          };
        };
      };
    };
    users.users = {
      syncthing.extraGroups = [ "users" ];
      "${swarm.user}".extraGroups = [ "syncthing" ];
    };
    systemd = {
      tmpfiles.rules = mkMerge [
        (builtins.map (folder: "d ${folder.path} 2770 ${swarm.user} syncthing") (
          builtins.attrValues config.services.syncthing.settings.folders
        ))
      ];
      services.syncthing = {
        environment.STNODEFAULTFOLDER = "true";
      };
    };
  };
}
