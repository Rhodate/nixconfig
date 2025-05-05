{
  stdenv,
  lib,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "GE-Proton9-27";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    sha256 = "sha256-u9MQi6jc8XPdKmDvTrG40H4Ps8mhBhtbkxDFNVwVGTc=";
  };

  buildCommand = ''
    mkdir -p $out
    tar -C $out --strip=1 -x -f $src
  '';
}
