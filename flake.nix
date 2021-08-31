{
  description = "Application packaged using poetry2nix";

  nixConfig.bash-prompt = "pybit~~$ ";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
            src = nixpkgs.lib.fetchFromGithub {
              owner = "verata-veritatis";
              repo = "pybit";
              rev = "ef8a6da6e18f7ea05c2c537a92861e70e6bc7fee";
              sha256 = "0pl9zyvn2n5p7q9c9zgb97x0795hc0lg2nmhjbggnqyplxyy7bp0";
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
          myapp = pkgs.myapp;
        };

        defaultApp = apps.myapp;

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.myapp
          ];
        };
      }
    ));
}
