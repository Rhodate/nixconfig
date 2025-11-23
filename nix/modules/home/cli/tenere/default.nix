{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.swarm.cli.tenere;
in
{
  options.swarm.cli.tenere = with types; {
    enable = mkOption {
      description = "Enable tenere";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tenere
    ];

    xdg.configFile."tenere/config.toml".text = ''
      llm = "ollama"
      [ollama]
      url = "http://localhost:11434/api/chat"
      model = "gemma3:27b"
    '';
  };
}
