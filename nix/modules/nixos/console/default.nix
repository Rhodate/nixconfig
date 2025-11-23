{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.swarm.console = {
    enable = mkOption {
      description = "Whether to configure the Linux TTY";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.swarm.console.enable {
    console = {
      packages = [
        pkgs.terminus_font
        pkgs.powerline-fonts
      ];
      font = "ter-powerline-v16b";
      useXkbConfig = true; # use xkb.options in tty.
    };
  };
}
