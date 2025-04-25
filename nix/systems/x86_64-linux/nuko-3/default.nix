{...}: {
  imports = [
    ../nuko/common.nix
  ];

  swarm.hardware.networking = {
    networkDevice = "eno1";
    hostId = "576851a4";
  };
}
