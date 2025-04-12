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
      default = false;
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
        ports = [222];
      };
      users.users.${swarm.user}.openssh.authorizedKeys.keys = [
        swarm.masterSshKey
      ];

      # Use persistent SSH keys
      environment.etc."ssh/ssh_host_rsa_key".source = "/etc/secrets/ssh/ssh_host_rsa_key";
      environment.etc."ssh/ssh_host_rsa_key.pub".source = "/etc/secrets/ssh/ssh_host_rsa_key.pub";
      environment.etc."ssh/ssh_host_ed25519_key".source = "/etc/secrets/ssh/ssh_host_ed25519_key";
      environment.etc."ssh/ssh_host_ed25519_key.pub".source = "/etc/secrets/ssh/ssh_host_ed25519_key.pub";
    };
}
