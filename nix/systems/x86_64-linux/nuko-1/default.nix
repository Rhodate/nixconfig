{ ... }:
{
  imports = [
    ../nuko/common.nix
  ];

  swarm.hardware.networking = {
    networkDevice = "eno1";
    hostId = "1c6150df";
  };
}
