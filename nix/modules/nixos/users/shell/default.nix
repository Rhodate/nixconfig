{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  # NOTE: ${swarm.user}'s default shell is a Home-manager option. This makes
  # adjustments to NixOS options based on ${swarm.user}'s Home-manager option.
  config = mkIf (config.swarm.users.enable && (builtins.hasAttr "${swarm.user}" config.home-manager.users)) (let
    shell = config.home-manager.users.${swarm.user}.swarm.cli.shell;
  in
    mkMerge [
      (mkIf (shell == "bash") {
        users.users.${swarm.user}.shell = pkgs.bash;
      })

      (mkIf (shell == "zsh") {
        users.users.${swarm.user}.shell = pkgs.zsh;
        programs.zsh.enable = true;
      })

      (mkIf (shell == "fish") {
        users.users.${swarm.user}.shell = pkgs.fish;
        programs.fish.enable = true;
      })

      (mkIf (shell == "nushell") {
        users.users.${swarm.user}.shell = pkgs.nushell;
      })
    ]);
}
