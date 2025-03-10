{inputs, ...}: rec {
  user = "rhoddy";
  masterSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC08NBlg0PwiuYEEJAo3WFLpd/JHz3wnqNyFhhgcYUH0 rhoddy@ophia";

  flakePath = "/home/${user}/swarm.flake";
}
