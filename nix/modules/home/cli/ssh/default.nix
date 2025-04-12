{
  config,
  lib,
  ...
}:
with lib; {
  options = {
    swarm.cli.ssh = {
      enable = mkOption {
        description = "Enable ssh";
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf config.swarm.cli.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks =
        mapAttrs (hostname: networkingConfig: {
          hostname = "${hostname}.${swarm.domainName}";
          user = swarm.user;
          port = 222;
        })
        swarm.networking;
    };
  };
}
