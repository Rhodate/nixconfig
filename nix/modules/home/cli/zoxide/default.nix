{
  config,
  lib,
  ...
}:
with lib;
{
  options.swarm.cli.zoxide = {
    enable = mkOption {
      description = "Enable zoxide cli util";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.zoxide.enable {
    programs.zoxide.enable = true;
  };
}
