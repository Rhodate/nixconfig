{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    swarm.sw
    disko
  ];

  swarm.hardware.networking.enable = false;
  swarm.users.enable = false;
  swarm.fs.type = "zfs";

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
