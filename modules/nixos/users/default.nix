{
  config,
  lib,
  ...
}:
with lib; {
  config = mkMerge [
    (mkIf (config.swarm.hardware.nvidia.enable || config.swarm.hardware.amdgpu.enable)  {
      users.users.${swarm.user}.extraGroups = [
        "video"
        "render"
      ];
    })

    (mkIf config.swarm.audio.enable {
      users.users.${swarm.user}.extraGroups = ["audio"];
    })
  ];
}
