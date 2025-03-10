{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.ssh = with pkgs; {
    enable = mkOption {
      description = "Enable sshd";
      type = types.bool;
      default = true;
    };
  };

  config = let
    cfg = config.swarm.ssh;
  in
    mkIf cfg.enable {
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
      };
      users.users.${swarm.user}.openssh.authorizedKeys.keys = [
        swarm.masterSshKey
      ];
    };
}
