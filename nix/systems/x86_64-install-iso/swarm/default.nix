{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    swarm.sw
    disko
  ];

  swarm.hardware.networking.enable = false;
  swarm.hardware.networking.firewall.enable = false;
  swarm.users.enable = false;

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = lib.swarm.publicKeys;
  };

  # Use NetworkManager.
  networking.wireless.enable = false;
  networking.networkmanager.enable = lib.mkForce true;

  # WARN: Removing this will cause the build to take forever.
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";
  hardware.enableRedistributableFirmware = true;
}
