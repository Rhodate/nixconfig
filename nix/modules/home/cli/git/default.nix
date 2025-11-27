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
      settings = {
        init.defaultBranch = "main";
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg = {
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          format = "ssh";
        };
        user = {
          name = "rhodate";
          email = "16692923+Rhodate@users.noreply.github.com";
          signingKey = "~/.ssh/id_ed25519.pub";
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        remote = {
          pushDefault = "origin";
        };
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
