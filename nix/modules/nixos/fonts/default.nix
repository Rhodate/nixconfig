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
        nerd-fonts.symbols-only
        fira-code
        fira-mono
        powerline-symbols
      ];
    };
  };
}
