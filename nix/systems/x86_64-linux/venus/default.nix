{
  modulesPath,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    "${inputs.nixpkgs}/nixos/maintainers/scripts/ec2/amazon-image.nix"
  ];

  virtualisation.diskSize = "auto";
  ec2.hvm = true;
  environment.enableAllTerminfo = true;
  environment.systemPackages = [
    pkgs.iotop
    pkgs.tcpdump
  ];
  security.sudo.wheelNeedsPassword = false;

  swarm = {
    hardware = {
      networking = {
        hostId = "d86dc3dc";
        networkDevice = "ens5";
        wireguard = {
          enable = true;
          privateKeyFile = "/etc/wireguard/privatekey";
        };
      };
    };
    virtualization = {
      enable = false;
      implementation = "docker";
    };
    ssh.enable = true;
    server = {
      k3s = {
        enable = true;
        role = "agent";
        externalIp = "2600:1f11:86:db03:fb8a:4f91:6b8:db58";
      };
    };
  };

  users.mutableUsers = false;

  system.stateVersion = "24.11";
}
