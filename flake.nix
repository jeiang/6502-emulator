{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls-main.url = "github:zigtools/zls";
    zls-main.inputs.nixpkgs.follows = "nixpkgs";
    zls-main.inputs.flake-utils.follows = "flake-utils";
    zls-main.inputs.zig-overlay.follows = "zig-overlay";
  };
  outputs = { flake-utils, nixpkgs, zig-overlay, zls-main, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (final: prev: {
            zigpkgs = zig-overlay.packages.${final.system};
            zls = zls-main.packages.${final.system}.zls;
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; };

        # TODO: grab this from something, rather than hard coding it, perhaps current folder name?
        pname = "6502-emulator";
        version = "0.1.0";
      in rec
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            inherit pname version;

            src = ./.;

            nativeBuildInputs = with pkgs; [
              zigpkgs.master
            ];

            ZIG_BUILD_FLAGS = "-p . --cache-dir . --global-cache-dir . -Dtarget=${system}";
            
            buildPhase = ''
              zig build $ZIG_BUILD_FLAGS
            '';

            doCheck = true;
            checkPhase = ''
              zig build test $ZIG_BUILD_FLAGS
            '';

            installPhase = ''
              mkdir -p $out/bin
              mv bin/* $out/bin
            '';
          };
        };
      
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            zigpkgs.master
            zls
          ];
        };

        # For compatibility with older versions of the `nix` binary
        devShell = devShells.${system}.default;
      });
}
