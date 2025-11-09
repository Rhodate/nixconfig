{
  lib,
  pkgs,
  config,
  ...
}: with lib; {
  options.swarm.desktop.tor = {
    enable = mkEnableOption "Enables tor";
  };

  config = mkIf config.swarm.desktop.tor.enable {
    environment.systemPackages = with pkgs; [
      tor-browser-bundle-bin
    ];
    services.tor = {
      enable = true;
      client.enable = true;
    };
  };
}
