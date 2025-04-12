{pkgs, ...}: {
  swarm = {
    desktop = {
      hyprland.enable = true;
      dunst.enable = true;
      waybar.enable = true;
      swww = {
        enable = false;
        defaultWallpaper = ./wallpapers/alexander-streng-ezgif-com-optimize.gif;
      };
      kitty.enable = true;
    };
    gaming = {
      proton-ge.enable = true;
    };
    fonts.enable = true;
    cli = {
      shell = "zsh";
      nvim.enable = true;
      zoxide.enable = true;
      direnv.enable = true;
      git.enable = true;
      btop.enable = true;
      newsboat.enable = true;
      tenere.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    k9s
    whois
    kubectl
    cryptsetup
    libressl_3_9
    kubernetes-helm
    yazi
    radeontop
    xdg-utils
    hwinfo
    kdePackages.kdenlive
    syncthing
    fastfetch
    xz
    element-desktop
    traceroute
    p7zip
    obs-studio
    timg
    unzip
    ripgrep
    deluge
    dnsutils
    handbrake
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
    gcc
    cmake
    gnumake
    autoconf
    dmidecode
    automake
    vulkan-tools
    glxinfo
    gimp
    libtool
    parted
    pavucontrol
    pulseaudio
    nodejs_22
    spotify
    libnotify
    wl-clipboard
    arandr
    inter
    playerctl
    killall
    blast
    vlc
    dotnetCorePackages.sdk_9_0
    jetbrains.rider
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7"
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "hyprctl setcursor Bibata-Modern-Ice 22"
    "kitty"
    "[workspace 2 silent] firefox"
    "[workspace 3 silent] discord"
    "[workspace 4 silent] spotify"
    "[workspace 5 silent] steam"
    "[workspace special silent] signal-desktop"
  ];

  home.stateVersion = "24.11";
}
