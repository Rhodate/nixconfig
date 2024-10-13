{
  lib,
  config,
  ...
}:
with lib; {
  options = {
    swarm.core.enable = mkOption {
      description = "Whether to enable core Home-manager options";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.swarm.core.enable {
    programs = {
      home-manager.enable = mkForce true; # Home-manager absolutely should stay enabled.
      nix-index.enable = true; # A files database for Nixpkgs.
    };

    home = {
      homeDirectory = mkForce "/home/${config.home.username}";
      sessionVariables = {
        GTK_THEME = "catppuccin-frappe-gtk";
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        NIXOS_OZONE_WL = 1;
      };
    };

    xdg = {
      enable = true;
      userDirs = let
        inherit (config.home) homeDirectory;
      in {
        enable = true;
        createDirectories = true;

        # Create these automatically.
        documents = "${homeDirectory}/Documents";
        music = "${homeDirectory}/Music";
        pictures = "${homeDirectory}/Images";
        videos = "${homeDirectory}/Videos";

        # Don't need these.
        publicShare = null;
        templates = null;
        desktop = null;
      };

      mime.enable = true;
      mimeApps = let
        mimes = {};
      in {
        enable = true;
        associations.added = mimes;
        defaultApplications = mimes;
      };
    };

    # Nicely reload user services on rebuild.
    systemd.user.startServices = "sd-switch";
  };
}
