{pkgs, ...}: {
  swarm = {
    desktop = {
      hyprland.enable = true;
      dunst.enable = true;
      waybar.enable = true;
      swww = {
        enable = true;
        defaultWallpaper = ./alexander-streng-ezgif-com-optimize.gif;
      };
      kitty.enable = true;
    };
    fonts.enable = true;
    cli = {
      shell = "zsh";
      nvim.enable = true;
      zoxide.enable = true;
      direnv.enable = true;
      git.enable = true;
      btop.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    cryptsetup
    openssl_3_3
    yazi
    kdenlive
    syncthing
    fastfetch
    xz
    p7zip
    obs-studio
    timg
    unzip
    ripgrep
    deluge
    dnsutils
    gnutar
    usbutils
    pciutils
    lsof
    firefox
    tor-browser-bundle-bin
    signal-desktop
    tree
    tmatrix
    discord
    webcord
    vesktop
    gcc
    cmake
    gnumake
    autoconf
    automake
    gimp
    libtool
    parted
    pavucontrol
    nodejs_22
    spotify
    libnotify
    wl-clipboard
    arandr
    inter
    playerctl
    swaybg
    killall
    playerctl
    blast
    vlc
    dotnetCorePackages.sdk_9_0
    jetbrains.rider
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "hyprctl setcursor Bibata-Modern-Ice 22"
    "swaybg -i ~/wallpaper -m fill"
    "kitty"
    "[workspace 2 silent] firefox"
    "[workspace 3 silent] discord"
    "[workspace 4 silent] spotify"
    "[workspace 5 silent] steam"
  ];

  home.stateVersion = "24.11";
}
