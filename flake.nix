{
  description = "Offline call graph generator for Python 3";

  nixConfig.bash-prompt = "pyan~~$ ";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      opkgs = import nixpkgs {};
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          pyan = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
            src = prev.fetchFromGitHub {
              owner = "codedepot-tech";
              repo = "pyan";
              rev = "367487d604113767f1273f8c138085e94572eb3b";
              sha256 = "0zxnxvill6i3dm5nmwdndnv8s1rnjw2pbf9r211hnqbdjp13ihih";
            };              
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      rec {
        apps = {
          pyan = pkgs.pyan;
        };

        defaultApp = apps.pyan;

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.pyan
          ];
        };
      }
    ));
}
