{
  pkgs,
  lib,
  ...
}:
with lib;
{
  config = {
    home.packages = [ pkgs.rust-bin.stable.latest.default ];
  };
}
