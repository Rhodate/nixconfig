{
  config,
  lib,
  ...
}:
with lib;
{
  options.swarm.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to configure the default user";
    };
  };
  config = mkIf config.swarm.users.enable (mkMerge [
    (mkIf (config.swarm.hardware.nvidia.enable || config.swarm.hardware.amdgpu.enable) {
      users.users.${swarm.user}.extraGroups = [
        "video"
        "render"
      ];
    })

    (mkIf config.swarm.audio.enable {
      users.users.${swarm.user}.extraGroups = [ "audio" ];
    })
  ]);
}
