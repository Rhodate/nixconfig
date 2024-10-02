{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.cli.nvim = {
    enable = mkOption {
      description = "Whether to install neovim on this system";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.nvim.enable {
    home.file.".config/nvim" = {
      source = ./config;
      recursive = true;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
  };
}
