{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.cli.ssh = {
    enable = mkOption {
      description = "Enable ssh";
      type = types.bool;
      default = false;
    };
    systems = mkOption {
      description = "All systems that exist, to be passed in from the main system configuration";
      type = types.listOf types.str;
    };
  };
  config = mkIf config.swarm.cli.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = mkMerge (map (hostname: {
          ${hostname} = {
            hostname = "${hostname}.${swarm.domainName}";
            user = swarm.user;
            port = 222;
          };
        })
        config.swarm.cli.ssh.systems);
    };
  };
}
