{
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        nerdfonts
        fira-code
        fira-mono
        powerline-symbols
      ];
    };
  };
}
