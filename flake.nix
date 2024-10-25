{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = bashlet;
          bashlet = pkgs.stdenv.mkDerivation {
            pname = "bashlet";
            version = "0.2";
            src = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/audacioustux/bashlets/main/bashlet.sh";
              sha256 = "0rjn6657ywr8gfr6gynazkxmx7icqca44jjxwk8xm60i5p2gsv4a";
            };
            phases = [ "installPhase" ];

            installPhase = ''
              install -Dm755 $src $out/bin/bashlet
            '';

            meta = with pkgs.lib; {
              homepage = "https://github.com/audacioustux/bashlets";
            };
          };
        };
      }
    );
}
