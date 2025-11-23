{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  options.swarm.cli.git = {
    enable = mkOption {
      description = "Whether this user needs git support";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.git.enable {
    programs.git = {
      enable = true;
      userName = "rhodate";
      userEmail = "16692923+Rhodate@users.noreply.github.com";

      extraConfig = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
        commit.gpgSign = true;
        tag.gpgSign = true;
        user.signingKey = "~/.ssh/id_ed25519.pub";
        # Not 100% sure if I ever actually configured this
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };

      lfs.enable = true;
    };
    programs.difftastic = {
      options = {
        display = "inline";
      };
      git = {
        enable = true;
      };
    };

    home.file.".ssh/allowed_signers".text = ''
      ${concatStringsSep "\n" (map (key: "* ${key}") lib.swarm.publicKeys)}
    '';

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
      extensions = with pkgs; [
        gh-markdown-preview
      ];
    };

    home.packages = with pkgs; [
      git-filter-repo
    ];
  };
}
