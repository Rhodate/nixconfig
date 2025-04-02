{lib, ...}: rec {
  user = "rhoddy";
  masterSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC08NBlg0PwiuYEEJAo3WFLpd/JHz3wnqNyFhhgcYUH0 rhoddy@ophia";

  ophia = {
    flakePath = "/home/${user}/swarm.flake";
    keyFile = "/nix/secrets/sops/age/keys.txt";
  };

  networking = {
    chito = {
      hostId = "d86dc3dc";
      networkDevice = "enp5s0";
    };
    ophia = {
      hostId = "36aa1853";
      networkDevice = "enp14s0";
    };
  };
  allMachineHostIds = lib.mapAttrsToList (machineName: networking: networking.hostId) networking;
}
