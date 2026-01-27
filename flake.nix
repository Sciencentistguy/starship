{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = manifest.name;
          version = manifest.version;

          src = pkgs.lib.cleanSource ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.installShellFiles
            pkgs.cmake
          ];

          postInstall = ''
            for shell in bash fish zsh; do
              STARSHIP_CACHE=$TMPDIR $out/bin/starship completions $shell > starship.$shell
              installShellCompletion starship.$shell
            done
          '';

          # Some tests might fail in the sandbox
          doCheck = false; 

          meta = with pkgs.lib; {
            description = manifest.description;
            homepage = manifest.homepage;
            license = licenses.isc;
            mainProgram = "starship";
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
          packages = with pkgs; [
            rust-analyzer
            clippy
            rustfmt
          ];
        };
      }
    );
}
