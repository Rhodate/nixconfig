{
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.swarm.cli.newsboat = {
    enable = mkOption {
      description = "Whether this user needs newsboat support";
      type = types.bool;
      default = false;
    };
  };

  config = {
    home.packages = with pkgs; [
      newsboat
    ];

    home.file.".newsboat/urls".text = ''
      https://nixos.org/blog/announcements-rss.xml
      https://neovim.io/news.xml
      https://dotfyle.com/this-week-in-neovim/rss.xml
      https://dotfyle.com/neovim/plugins/rss.xml
      https://discourse.nixos.org/c/links.rss
    '';

    home.file.".newsboat/config".text = ''
      include ${./dark.theme}
    '';
  };
}
