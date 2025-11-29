{
  pkgs,
  inputs,
  system,
  ...
}:
{
  swarm = {
    desktop = {
      hyprland.enable = true;
      dunst.enable = true;
      quickshell.enable = true;
      kitty.enable = true;
    };
    gaming = {
      proton-ge.enable = true;
    };
    fonts.enable = true;
    cli = {
      shell = "zsh";
      ssh.enable = true;
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
    inputs.quickshell.packages.${system}.default
    swarm.find-kitty-tab
    k9s
    tea
    whois
    kubectl
    cryptsetup
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
    opencode
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7"
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.uwsm}/bin/uwsm app -- hyprctl setcursor Bibata-Modern-Ice 22"
    "${pkgs.uwsm}/bin/uwsm app -- kitty"
    "[workspace 2 silent] ${pkgs.uwsm}/bin/uwsm app -- firefox"
    "[workspace 4 silent] ${pkgs.uwsm}/bin/uwsm app -- spotify"
    "[workspace 5 silent] ${pkgs.uwsm}/bin/uwsm app -- steam"
    "[workspace special silent] ${pkgs.uwsm}/bin/uwsm app -- signal-desktop"
  ];

  home.stateVersion = "24.11";
}
