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
            src = prev.fetchgit {
              # owner = "codedepot-tech";
              # repo = "pyan";
              url = "https://github.com/codedepot-tech/pyan.git";
              rev = "350ea49687b93d5b31afa0778ccf732b6151f874";
              sha256 = "0qwh5ywfs2x1b8brxzbka1h2hvvr8y58zhdxrxk8fm5xkchvxj6k";
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
