{
  config,
  inputs,
  system,
  lib,
  ...
}:
with lib;
{
  options = {
    swarm.desktop.quickshell.enable = mkEnableOption "Enable quickshell";
  };
  config = mkIf config.swarm.desktop.quickshell.enable (mkMerge [
    {
      programs.quickshell = {
        enable = true;
        package = inputs.quickshell.packages.${system}.default;
        systemd = {
          enable = true;
        };
      };
    }
  ]);
}
