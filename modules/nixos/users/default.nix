{
  config,
  lib,
  ...
}:
with lib; {
  config = mkMerge [
    (mkIf config.swarm.hardware.nvidia.enable {
      users.users.${swarm.user}.extraGroups = [
        "video"
        "render"
        "builder"
      ];
    })

    (mkIf config.swarm.audio.enable {
      users.users.${swarm.user}.extraGroups = ["audio"];
    })
  ];
}
