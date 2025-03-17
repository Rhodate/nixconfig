{lib, ...}:
with lib; {
  options.swarm.cli = {
    shell = mkOption {
      description = "Which shell to use as default";
      type = types.enum [
        "bash" # TODO: Implement shell/<shell>.nix modules.
        "zsh"
      ];
      default = "zsh";
    };
  };
}
