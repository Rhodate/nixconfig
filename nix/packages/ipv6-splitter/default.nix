{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "ipv6-splitter";
  src = builtins.path {
    path = ./ipv6_splitter.pl;
    name = "ipv6_splitter.pl";
  };

  buildInputs = [
    pkgs.perl
    pkgs.perlPackages.Socket
    pkgs.perlPackages.MathBigInt
    pkgs.perlPackages.DigestMD5
  ];

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ipv6-splitter
    chmod +x $out/bin/ipv6-splitter
    substituteInPlace $out/bin/ipv6-splitter \
      --replace "#!/usr/bin/perl" "#!${pkgs.perl}/bin/perl"
  '';

  meta = {
    description = "Splits IPv6 CIDR blocks into non-overlapping blocks of varying sizes based on string seeds.";
    longDescription = ''
      This tool splits an IPv6 CIDR block into smaller, non-overlapping blocks of varying sizes based on string seeds,
      ensuring deterministic generation. It requires perl, Socket, Math::BigInt, and Digest::MD5 modules.
      Usage: ipv6-splitter <cidr> <block_size1> [<block_size2> ...] <seed1> [<seed2> ...]
    '';
    homepage = null; # Replace with a homepage if you have one
    license = pkgs.lib.licenses.mit; # Choose appropriate license
    maintainers = []; # Add your nixos.github account here.
  };
}
