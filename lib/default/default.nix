{inputs, ...}: rec {
  user = "rhoddy";
  masterSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC08NBlg0PwiuYEEJAo3WFLpd/JHz3wnqNyFhhgcYUH0";

  flakePath = "/home/${user}/swarm.flake";

  nix = {
    distributedBuilds = true;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://cuda-maintainers.cachix.org"
        # "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];

      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      generateNixPathFromInputs = true;
      generateRegistryFromInputs = true;
      linkInputs = true;
      trusted-users = [ "@wheel" ];
    };
  };
}
