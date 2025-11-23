{
  config,
  lib,
  ...
}:
with lib;
{
  options.swarm.hardware = {
    firmware = mkOption {
      type =
        with types;
        enum [
          "free"
          "redistributable"
          "all"
        ];
      default = "redistributable";
    };
  };

  config =
    let
      firmware = config.swarm.hardware.firmware;
    in
    mkMerge [
      (mkIf (firmware == "redistributable") {
        hardware.enableRedistributableFirmware = true;
      })

      (mkIf (firmware == "all") {
        hardware.enableAllFirmware = true;
      })

      (mkIf (firmware == "redistributable" || firmware == "all") {
        hardware = {
          cpu = {
            amd.updateMicrocode = true;
            intel.updateMicrocode = true;
          };
        };
      })
    ];
}
