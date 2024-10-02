{
  config,
  lib,
  ...
}:
with lib; {
  options.swarm.cli.fzf = {
    enable = mkOption {
      description = "Enable fzf cli util";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.swarm.cli.fzf.enable {
    programs.fzf = {
      enable = true;
      colors = {
        "bg+" = "#313244";
        bg = "#1e1e2e";
        spinner = "#f5e0dc";
        lhl = "#f38ba8";
        fg = "#cdd6f4";
        header = "#f38ba8";
        info = "#cba6f7";
        pointer = "#f5e0dc";
        marker = "#b4befe";
        "fg+" = "#cdd6f4";
        prompt = "#cba6f7";
        "hl+" = "#f38ba8";
        selected-bg = "#45475a";
      };
    };
  };
}
