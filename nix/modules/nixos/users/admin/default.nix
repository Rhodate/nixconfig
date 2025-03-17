{
  config,
  lib,
  ...
}:
with lib; let
  # Only add these groups if they are present to avoid clutter.
  ifPresent = with builtins;
    groups: filter (G: hasAttr G config.users.groups) groups;
in {
  config = {
    users.users.${swarm.user}.extraGroups =
      [
        "wheel"
        "input"
      ]
      ++ ifPresent [
        "networkmanager"
        "docker"
        "podman"
        "git"
        "lxd"
      ];
  };
}
