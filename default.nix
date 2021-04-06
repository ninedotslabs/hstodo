with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "hstodo";
  src = ./.;
  buildInputs = [ghc];
  installPhase = ''
    mkdir -p $out/bin
    ghc --make Main.hs -o $out/bin/$name
  '';
}
