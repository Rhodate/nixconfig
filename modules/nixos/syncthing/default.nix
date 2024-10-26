{
  lib,
  config,
  ...
}:
with lib; {
  options.swarm.syncthing = {
    enable = mkEnableOption "Enable syncthing";
  };

  config = mkIf config.swarm.syncthing.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      key = "${./myconfig/key.pem}";
      cert = "${./myconfig/cert.pem}";
      user = "syncthing";
      settings = {
        devices = {
          "galazy-s23-ultra" = {id = "ELKEX3W-EUIIOUM-QONMXGQ-EMMTNE7-HNVFSG2-EIUQHU5-QJ7GWGB-U4PVTQB";};
        };
        folders = {
          "Images" = {
            path = "/home/rhoddy/Images";
            id = "tfxqa-ug4ve";
            devices = ["galazy-s23-ultra"];
          };
        };
      };
    };
    users.users = {
      syncthing.extraGroups = ["users"];
      "${swarm.user}".extraGroups = ["syncthing"];
    };
    systemd = {
      tmpfiles.rules = mkMerge [
        ["d /home/${swarm.user} 0750 ${swarm.user} syncthing"]
        (builtins.map (folder: "d ${folder.path} 2770 ${swarm.user} syncthing") (builtins.attrValues config.services.syncthing.settings.folders))
      ];
      services.syncthing = {
        environment.STNODEFAULTFOLDER = "true";
        serviceConfig.UMask = "0007";
      };
    };
  };
}
