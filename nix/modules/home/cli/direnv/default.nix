{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.cli.direnv = {
    enable = mkOption {
      description = "Enable direnv cli util";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    services.lorri.enable = true;
  };
}
