{pkgs, ...}: {
  swarm = {
    cli = {
      shell = "zsh";
      nvim.enable = true;
      zoxide.enable = true;
      btop.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    libressl_3_9
    traceroute
    dnsutils
    usbutils
    pciutils
    lsof
    killall
    k9s
  ];

  home.stateVersion = "24.11";
}
