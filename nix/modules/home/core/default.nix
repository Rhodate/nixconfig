{
  lib,
  config,
  ...
}:
with lib;
{
  options = {
    swarm.core.enable = mkOption {
      description = "Whether to enable core Home-manager options";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.swarm.core.enable {
    programs = {
      home-manager.enable = mkForce true;

      # Use nix-index for command not found.
      command-not-found.enable = false;
      nix-index.enable = true;
    };

    home = {
      homeDirectory = mkForce "/home/${config.home.username}";
      sessionVariables = {
        GTK_THEME = "catppuccin-frappe-gtk";
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };

    xdg = {
      enable = true;
      userDirs =
        let
          inherit (config.home) homeDirectory;
        in
        {
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
      mimeApps =
        let
          mimes = { };
        in
        {
          enable = true;
          associations.added = mimes;
          defaultApplications = mimes;
        };
    };

    # Nicely reload user services on rebuild.
    systemd.user.startServices = "sd-switch";
  };
}
